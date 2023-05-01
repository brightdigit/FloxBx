import Combine
import FloxBxAuth
import FloxBxRequests
import Foundation
import Prch

extension Result {
  public init(
    _ asyncFunc: @escaping () async throws -> Success
  ) async where Failure == Error {
    let success: Success
    do {
      success = try await asyncFunc()
    } catch {
      self = .failure(error)
      return
    }
    self = .success(success)
  }

  public func tryMap<NewSuccess>(
    _ transform: @escaping (Success) throws -> (NewSuccess)
  ) -> Result<NewSuccess, Error> {
    let oldValue: Success
    let newValue: NewSuccess
    switch self {
    case let .success(value):
      oldValue = value

    case let .failure(error):
      return .failure(error)
    }
    do {
      newValue = try transform(oldValue)
    } catch {
      return .failure(error)
    }
    return .success(newValue)
  }

  public func asError() -> Failure? where Success == Void {
    guard case let .failure(error) = self else {
      return nil
    }
    return error
  }
}

struct AuthenticationError: LocalizedError {
  internal init(innerError: Error) {
    self.innerError = innerError
  }

  let innerError: Error

  var errorDescription: String? {
    innerError.localizedDescription
  }
}

class AuthorizationObject: ObservableObject {
  internal init(service: any AuthorizedService, account: Account? = nil) {
    self.service = service
    self.account = account

    let refreshPublisher = refreshSubject.map {
      Future {
        try await self.service.fetchCredentials()
      }
    }
    .switchToLatest()
    .compactMap { $0 }
    .map { Account(username: $0.username) }
    .mapError(AuthenticationError.init)
    .share()

    refreshPublisher.map(Optional.some).catch { _ in Just(Optional.none) }.compactMap { $0 }.subscribe(accountSubject).store(in: &cancellables)

    refreshPublisher.map { _ in AuthenticationError?.none }.catch { Just(Optional.some($0)) }.compactMap { $0 }.subscribe(errorSubject).store(in: &cancellables)

    // successfulCompletedSubject.map(Optional.some).receive(on: DispatchQueue.main).assign(to: &self.$account)

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

    let authenticationResult = authenticateSubject.map { credentials, isNew in
      Future { () async throws -> Credentials in
        let token: String
        if isNew {
          token = try await self.service.request(SignUpRequest(body: .init(emailAddress: credentials.username, password: credentials.password))).token
        } else {
          token = try await self.service.request(SignInCreateRequest(body: .init(emailAddress: credentials.username, password: credentials.password))).token
        }
        return credentials.withToken(token)
      }
    }
    .switchToLatest()
    .tryMap { credentials in
      try self.service.save(credentials: credentials)
      return Account(username: credentials.username)
    }
    .share()
    // .share()

    authenticationResult.map(Optional.some).catch { _ in Just(Optional.none) }.compactMap { $0 }.subscribe(accountSubject).store(in: &cancellables)
    authenticationResult.mapError(AuthenticationError.init).map { _ in AuthenticationError?.none }.catch { Just(Optional.some($0)) }.compactMap { $0 }.subscribe(errorSubject).store(in: &cancellables)

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
