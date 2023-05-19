import FloxBxAuth
import Prch

extension CredentialsContainer: StealthyManager {
  public func fetch() async throws -> AuthorizationType? {
    let creds: Credentials? = try await fetch()
    return creds
  }

  public typealias AuthorizationType = SessionAuthorization
}
