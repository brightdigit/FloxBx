import FloxBxAuth
import FloxBxRequests
import Prch

public protocol AuthorizedService: ServiceProtocol {
  func save(credentials: Credentials) throws

  func resetCredentials() throws

  func fetchCredentials() async throws -> Credentials?
}

extension Service: AuthorizedService {
  public func save(credentials _: FloxBxAuth.Credentials) throws {
    // try credentialsContainer.save(credentials: credentials)
    fatalError()
  }

  public func resetCredentials() throws {
    fatalError()
    // try credentialsContainer.reset()
  }

  public func fetchCredentials() async throws -> FloxBxAuth.Credentials? {
    try await authorizationManager.fetch()

    // try await credentialsContainer.fetch()
  }
}

// extension ServiceImpl : AuthorizedService where AuthorizationContainerType == CredentialsContainer {
//
//
//
// }

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
