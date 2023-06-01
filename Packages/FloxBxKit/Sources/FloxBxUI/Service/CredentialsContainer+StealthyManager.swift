import FloxBxAuth
import Prch

extension CredentialsContainer: StealthyManager {
  public typealias AuthorizationType = SessionAuthorization

  public func fetch() async throws -> AuthorizationType? {
    let creds: Credentials? = try await fetch()
    return creds
  }
}
