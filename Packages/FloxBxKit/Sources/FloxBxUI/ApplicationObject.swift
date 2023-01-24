import FloxBxAuth
import FloxBxGroupActivities
import FloxBxModels
import FloxBxNetworking
import Sublimation

#if canImport(Combine) && canImport(SwiftUI) && canImport(UserNotifications)
  import Combine
  import SwiftUI
  import UserNotifications

  internal class ApplicationObject: ObservableObject {
    @Published internal private(set) var shareplayObject: SharePlayObject<
      TodoListDelta, GroupActivityConfiguration, UUID
    >

    internal var cancellables = [AnyCancellable]()

    // swiftlint:disable:next line_length
    internal let mobileDevicePublisher: AnyPublisher<CreateMobileDeviceRequestContent?, Never>
    @AppStorage("MobileDeviceRegistrationID")
    internal private(set) var mobileDeviceRegistrationID: String?
    @Published internal var requiresAuthentication: Bool
    @Published internal private(set) var latestError: Error?
    @Published internal private(set) var token: String?
    @Published internal private(set) var username: String?
    @Published internal var items = [TodoContentItem]()

    #if DEBUG
      // swiftlint:disable:next implicitly_unwrapped_optional
    internal var service: (any CredentialsService)!
    #else
      internal let service: Service = ServiceImpl(
        baseURL: Configuration.productionBaseURL,
        accessGroup: Configuration.accessGroup,
        serviceName: Configuration.serviceName
      )
    #endif

    internal init(
      mobileDevicePublisher: AnyPublisher<CreateMobileDeviceRequestContent?, Never>,
      _ items: [TodoContentItem] = []
    ) {
      self.mobileDevicePublisher = mobileDevicePublisher
      shareplayObject = .createNew()
      requiresAuthentication = true

      $token
        .map { $0 == nil }
        .receive(on: DispatchQueue.main)
        .assign(to: &$requiresAuthentication)

      let groupSessionIDPub = shareplayObject.$groupActivityID

      $token
        .share()
        .compactMap { $0 }
        .combineLatest(groupSessionIDPub)
        .map(\.1)
        .flatMap(getTodoListFrom)
        .mapEach(TodoContentItem.init)
        .replaceError(with: [])
        .receive(on: DispatchQueue.main)
        .assign(to: &$items)

      if #available(iOS 15, macOS 12, *) {
        #if canImport(GroupActivities)
          self.shareplayObject.messagePublisher
            .sink(receiveValue: self.handle(_:))
            .store(in: &self.cancellables)
        #endif
      }

      self.items = items
    }

    internal func onError(_ error: Error) {
      Task { @MainActor in
        self.latestError = error
      }
    }

    internal func authenticationComplete(
      withUser username: String?,
      andToken token: String?
    ) {
      Task { @MainActor in
        self.username = username
        self.token = token
      }
    }

    internal func updateMobileDeviceRegistrationID(
      _ updateMobileDeviceRegistrationID: String
    ) {
      mobileDeviceRegistrationID = updateMobileDeviceRegistrationID
    }
  }

#endif
#if canImport(Security)
public protocol CredentialsService : Service {
  func save(credentials: Credentials) throws
  func resetCredentials() throws -> Credentials.ResetResult
  func fetchCredentials() throws -> Credentials?
}
extension ServiceImpl : CredentialsService where AuthorizationContainerType: CredentialsContainer{
  
    public func save(credentials: Credentials) throws {
      try credentialsContainer.save(credentials: credentials)
    }
  
    public func resetCredentials() throws -> Credentials.ResetResult {
      try credentialsContainer.reset()
    }
  
    public func fetchCredentials() throws -> Credentials? {
      try credentialsContainer.fetch()
    }
}
extension Credentials : Authorization {
  public var httpHeaders: [String : String] {
    guard let token = self.token else {
      return [:]
    }
    return ["Authorization": "Bearer \(token)"]
  }
  
  
}

extension KeychainContainer : AuthorizationContainer {
  public typealias AuthorizationType = Credentials
  

  
}

  extension ServiceImpl {
    public convenience init(
      baseURL: URL,
      accessGroup: String,
      serviceName: String,
      headers: [String: String] = ["Content-Type": "application/json; charset=utf-8"],
      coder: JSONCoder = .init(encoder: JSONEncoder(), decoder: JSONDecoder()),
      session: URLSession = .shared
    ) where
      RequestBuilderType == URLRequestBuilder,
      SessionType == URLSession,
      CoderType == JSONCoder,
      AuthorizationContainerType == KeychainContainer {
      guard let baseURLComponents = URLComponents(
        url: baseURL,
        resolvingAgainstBaseURL: false
      ) else {
        preconditionFailure("Invalid baseURL: \(baseURL)")
      }
        
      self.init(
        baseURLComponents: baseURLComponents,
        coder: coder,
        session: session,
        builder: .init(),
        credentialsContainer:
        KeychainContainer(
          accessGroup: accessGroup,
          serviceName: serviceName
        ),
        headers: headers
      )
    }
  }
#endif
