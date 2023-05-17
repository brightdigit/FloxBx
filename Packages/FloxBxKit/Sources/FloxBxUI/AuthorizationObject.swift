#if canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxRequests
  import Foundation
  import Prch

  class AuthorizationObject: ObservableObject {
    // swiftlint:disable:next function_body_length
    internal init(service: any AuthorizedService, account: Account? = nil) {
      self.service = service
      self.account = account

      let refreshPublisher = refreshSubject.flatMap {
        Future {
          try await self.service.fetchCredentials()
        }
      }
      .compactMap { $0 }
      .map { Account(username: $0.username) }
      .mapError(AuthenticationError.init)
      .share()

      refreshPublisher
        .map(Optional.some)
        .catch { _ in Just(Optional.none) }
        .compactMap { $0 }
        .subscribe(accountSubject)
        .store(in: &cancellables)

      refreshPublisher
        .map { _ in AuthenticationError?.none }
        .catch { Just(Optional.some($0)) }
        .compactMap { $0 }
        .subscribe(errorSubject)
        .store(in: &cancellables)

      let logoutCompleted = logoutCompletedSubject.share()

      logoutCompleted.compactMap {
        (try? $0.get()).map {
          nil
        }
      }
      .subscribe(accountSubject).store(in: &cancellables)

      logoutCompleted.compactMap {
        $0.asError().map(AuthenticationError.init)
      }.subscribe(errorSubject).store(in: &cancellables)

      let authenticationResult = authenticateSubject.flatMap { credentials, isNew in
        Future { () async throws -> Credentials in
          let token: String
          if isNew {
            token = try await self.service
              .request(
                SignUpRequest(body: .init(
                  emailAddress: credentials.username,
                  password: credentials.password
                ))
              ).token
          } else {
            token = try await self.service
              .request(
                SignInCreateRequest(body: .init(
                  emailAddress: credentials.username,
                  password: credentials.password
                ))
              ).token
          }
          return credentials.withToken(token)
        }
      }
      .tryMap { credentials in
        try self.service.save(credentials: credentials)
        return Account(username: credentials.username)
      }
      .share()

      authenticationResult
        .map(Optional.some)
        .catch { _ in Just(Optional.none) }
        .compactMap { $0 }
        .subscribe(accountSubject)
        .store(in: &cancellables)
      authenticationResult
        .mapError(AuthenticationError.init)
        .map { _ in AuthenticationError?.none }
        .catch { Just(Optional.some($0)) }
        .compactMap { $0 }
        .subscribe(errorSubject)
        .store(in: &cancellables)

      errorSubject.map(Optional.some).receive(on: DispatchQueue.main).assign(to: &$error)
      accountSubject.receive(on: DispatchQueue.main).assign(to: &$account)
    }

    let service: any AuthorizedService
    @Published var account: Account?
    @Published var error: AuthenticationError?
    let logoutCompletedSubject = PassthroughSubject<Result<Void, Error>, Never>()
    let authenticateSubject = PassthroughSubject<(Credentials, Bool), Never>()
    let refreshSubject = PassthroughSubject<Void, Never>()
    let errorSubject = PassthroughSubject<AuthenticationError, Never>()
    let accountSubject = PassthroughSubject<Account?, Never>()

    var cancellables = [AnyCancellable]()

    internal func beginSignup(withCredentials credentials: Credentials) {
      authenticateSubject.send((credentials, true))
    }

    func beginSignIn(withCredentials credentials: Credentials) {
      authenticateSubject.send((credentials, false))
    }

    func logout() {
      let result = Result {
        try service.resetCredentials()
      }
      logoutCompletedSubject.send(result)
    }
  }
#endif
