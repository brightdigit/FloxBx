import FloxBxAuth
import FloxBxGroupActivities
import FloxBxModels
import FloxBxNetworking
import Sublimation
import UserNotifications

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
      internal var service: Service!
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

      self.mobileDevicePublisher.flatMap { content in
        
        return Future { () -> UUID? in
          if let id = self.mobileDeviceRegistrationID.flatMap(UUID.init(uuidString: )) {
            try await self.service.request(PatchMobileDeviceRequest(id: id, body: .init(createContent: content)))
            return nil
          } else {
            return try await self.service.request(CreateMobileDeviceRequest(body: content)).id
          }
        }
      }
      .replaceError(with: nil)
      .compactMap{$0?.uuidString}
      .receive(on: DispatchQueue.main)
      .sink { id in
        self.mobileDeviceRegistrationID = id
      }
      
      
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
