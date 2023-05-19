import FloxBxAuth
import Prch

protocol StealthyManager<AuthorizationType>: AuthorizationManager {
  func fetch() async throws -> Credentials?

  func save(credentials: Credentials) throws

  func reset() throws
}
