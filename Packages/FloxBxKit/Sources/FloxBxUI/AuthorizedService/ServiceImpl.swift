import Combine
import FloxBxAuth
import FloxBxRequests
import Foundation
import Prch
import PrchModel
import StealthyStash
import Sublimation

protocol PublishingBaseURLProvider: BaseURLProvider {
  var baseURLComponentsPublisher: AnyPublisher<URLComponents, Never> { get }
}

extension Result {
  func unwrap<NewSuccess>(_ error: @autoclosure () -> Failure) -> Result<NewSuccess, Failure> where Success == NewSuccess? {
    flatMap { success in
      guard let newSuccess = success else {
        return .failure(error())
      }
      return .success(newSuccess)
    }
  }
}

class TunnelBaseURLProvider<TunnelRepositoryType: TunnelRepository>: PublishingBaseURLProvider {
  internal init(key: TunnelRepositoryType.Key, repository: TunnelRepositoryType) {
    self.key = key
    self.repository = repository

    baseURLComponentsResultSubject
      .map { try? $0.get() }
      .assign(to: &$baseURL)

    Task {
      let baseURLResult = await Result {
        try await self.repository.tunnel(forKey: key)
      }.unwrap(DeveloperServerError.noServer)
      self.baseURLComponentsResultSubject.send(baseURLResult)
    }
  }

  let key: TunnelRepositoryType.Key
  let repository: TunnelRepositoryType

  var baseURLResult: Result<URL, Error>?

  @Published var baseURL: URL?

  let baseURLComponentsResultSubject = PassthroughSubject<Result<URL, Error>, Never>()

  var baseURLComponentsPublisher: AnyPublisher<URLComponents, Never> {
    $baseURL
      .compactMap { $0 }
      .compactMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
      .eraseToAnyPublisher()
  }

  var baseURLComponents: URLComponents? {
    baseURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
  }
}

#if canImport(Security)

//  extension KeychainRepository: AuthorizationManager {
//    public func fetch() async throws -> AuthorizationType? {
//      let creds: Credentials? = try await fetch()
//      return creds
//    }
//
//    public typealias AuthorizationType = URLSessionAuthorization
//  }

  extension FloxBxService {
    public convenience init(
      host: String,
      accessGroup: String,
      serviceName: String,
      urlBucketName: String,
      key: String,
      session: URLSession = .shared
    ) where
      SessionType == URLSession {
        let tunnelRepo = TunnelBaseURLProvider(key: key, repository: KVdbTunnelRepository<String>(client: URLSessionClient(session: session), bucketName: urlBucketName))
      let repository = KeychainRepository(
        defaultServiceName: serviceName,
        defaultServerName: host,
        defaultAccessGroup: accessGroup
      )

      let api = FloxBxAPI(baseURLProvider: tunnelRepo)
      self.init(api: api, session: session, repository: CredentialsContainer(repository: repository), isReadyPublisher: tunnelRepo.$baseURL.map { $0 != nil }.eraseToAnyPublisher())
    }

//    public convenience init(
//      baseURL: URL,
//      accessGroup: String,
//      serviceName: String,
//      headers: [String: String] = ["Content-Type": "application/json; charset=utf-8"],
//      coder: JSONCoder = .init(encoder: JSONEncoder(), decoder: JSONDecoder()),
//      session: URLSession = .shared
//    ) where
//      SessionType == URLSession {
//      guard let baseURLComponents = URLComponents(
//        url: baseURL,
//        resolvingAgainstBaseURL: false
//      ), let host = baseURL.host ?? baseURLComponents.host else {
//        preconditionFailure("Invalid baseURL: \(baseURL)")
//      }
//
//      let repository = KeychainRepository(
//        defaultServiceName: serviceName,
//        defaultServerName: host,
//        defaultAccessGroup: accessGroup
//      )
//
//      self.init(
//        baseURLComponents: baseURLComponents,
//        headers: headers,
//        session: session,
//        coder: coder,
//        repository: CredentialsContainer(repository: repository)
//      )
//    }
  }
#endif
