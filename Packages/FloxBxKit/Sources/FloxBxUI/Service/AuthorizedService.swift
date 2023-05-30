#if canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxRequests

  public protocol AuthorizedService: FloxBxServiceProtocol {
    func save(credentials: Credentials) throws

    func resetCredentials() throws

    func fetchCredentials() async throws -> Credentials?

    var isReadyPublisher: AnyPublisher<Bool, Never> { get }
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
#endif
