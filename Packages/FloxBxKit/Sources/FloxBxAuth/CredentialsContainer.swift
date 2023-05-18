import StealthyStash

public class CredentialsContainer {
  public init(repository: StealthyRepository, credentials: Credentials? = nil) {
    self.credentials = credentials
    self.repository = repository
  }

  var credentials: Credentials?
  let repository: StealthyRepository

  public func fetch() async throws -> Credentials? {
    let credentials: Credentials? = try await repository.fetch()
    self.credentials = credentials
    return credentials
  }

  public func save(credentials: Credentials) throws {
    if let oldCredentials = self.credentials {
      try repository.update(from: oldCredentials, to: credentials)
    } else {
      try repository.create(credentials)
    }
  }

  public func reset() throws {
    guard let credentials = credentials else {
      return
    }

    try repository.delete(credentials)
    self.credentials = nil
  }
}
