#if canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxRequests
  import Foundation
  import Prch
  import PrchModel
  import StealthyStash

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
#endif
