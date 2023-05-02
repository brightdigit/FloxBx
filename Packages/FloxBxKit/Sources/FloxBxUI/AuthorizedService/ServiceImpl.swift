import FloxBxAuth
import Foundation
import Prch
import PrchModel
import StealthyStash

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
      baseURL: URL,
      accessGroup: String,
      serviceName: String,
      headers: [String: String] = ["Content-Type": "application/json; charset=utf-8"],
      coder: JSONCoder = .init(encoder: JSONEncoder(), decoder: JSONDecoder()),
      session: URLSession = .shared
    ) where
      SessionType == URLSession {
      guard let baseURLComponents = URLComponents(
        url: baseURL,
        resolvingAgainstBaseURL: false
      ), let host = baseURL.host ?? baseURLComponents.host else {
        preconditionFailure("Invalid baseURL: \(baseURL)")
      }

      let repository = KeychainRepository(
        defaultServiceName: serviceName,
        defaultServerName: host,
        defaultAccessGroup: accessGroup
      )

      self.init(
        baseURLComponents: baseURLComponents,
        headers: headers,
        session: session,
        coder: coder,
        repository: CredentialsContainer(repository: repository)
      )
    }
  }
#endif
