import FloxBxAuth
import FloxBxRequests
import Foundation
import Prch
import PrchModel
import StealthyStash

protocol StealthyManager<AuthorizationType>: AuthorizationManager {
  func fetch() async throws -> Credentials?

  func save(credentials: Credentials) throws

  func reset() throws
}

extension CredentialsContainer: StealthyManager {
  public func fetch() async throws -> AuthorizationType? {
    let creds: Credentials? = try await fetch()
    return creds
  }

  public typealias AuthorizationType = SessionAuthorization
}

class FloxBxService<SessionType: Session>: Service where SessionType.ResponseType.DataType == Data, SessionType.RequestDataType == Data {
  internal init(api: FloxBxAPI, session: SessionType, repository: any StealthyManager<SessionType.AuthorizationType>) {
    self.api = api
    self.session = session
    self.repository = repository
  }

  var api: FloxBxRequests.FloxBxAPI

  var session: SessionType

  typealias ServiceAPI = FloxBxAPI

//  internal init(
//    baseURLComponents: URLComponents,
//    headers: [String: String],
//    session: SessionType,
//    coder: any Coder<SessionType.ResponseType.DataType>,
//    repository: any StealthyManager<SessionType.AuthorizationType>
//  ) {
//    self.baseURLComponents = baseURLComponents
//    self.headers = headers
//    self.session = session
//    self.coder = coder
//    self.repository = repository
//  }
//
  var authorizationManager: any AuthorizationManager<SessionType.AuthorizationType> {
    repository
  }

//
//  let baseURLComponents: URLComponents
//
//  let headers: [String: String]
//
//  let session: SessionType
//
//  let coder: any Coder<SessionType.ResponseType.DataType>
//
  let repository: any StealthyManager<SessionType.AuthorizationType>
}

public protocol AuthorizedService: FloxBxServiceProtocol {
  func save(credentials: Credentials) throws

  func resetCredentials() throws

  func fetchCredentials() async throws -> Credentials?
}

extension FloxBxService: AuthorizedService {
  public func save(credentials: FloxBxAuth.Credentials) throws {
    try repository.save(credentials: credentials)
  }

  public func resetCredentials() throws {
    try repository.reset()
  }

  public func fetchCredentials() async throws -> FloxBxAuth.Credentials? {
    try await repository.fetch()
  }
}

extension AuthorizedService {
  func verifyLogin() async throws -> Bool {
    guard let credentials = try await fetchCredentials() else {
      return false
    }

    let newToken: String
    do {
      let tokenContainer = try await request(SignInRefreshRequest())
      newToken = tokenContainer.token
    } catch {
      newToken = try await request(
        SignInCreateRequest(
          body: .DecodableType(
            emailAddress: credentials.username,
            password: credentials.password
          )
        )
      ).token
    }

    try save(credentials: credentials.withToken(newToken))
    return true
  }
}
