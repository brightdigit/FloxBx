import FloxBxAuth
import Prch

internal protocol StealthyManager<AuthorizationType>: AuthorizationManager {
  func fetch() async throws -> Credentials?

  func save(credentials: Credentials) throws

  func reset() throws
}
