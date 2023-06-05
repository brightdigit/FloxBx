#if canImport(Combine) && DEBUG
  import Combine
  import Foundation
  import Sublimation

  internal class TunnelBaseURLProvider<
    TunnelRepositoryType: TunnelRepository
  >: PublishingBaseURLProvider {
    private let key: TunnelRepositoryType.Key
    private let repository: TunnelRepositoryType

    internal private(set) var baseURLResult: Result<URL, Error>?

    @Published internal private(set) var baseURL: URL?

    private let baseURLComponentsResultSubject =
      PassthroughSubject<Result<URL, Error>, Never>()

    internal var isReadyPublisher: AnyPublisher<Bool, Never> {
      $baseURL.map { $0 != nil }.eraseToAnyPublisher()
    }

    internal var baseURLComponents: URLComponents? {
      baseURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
    }

    internal init(key: TunnelRepositoryType.Key, repository: TunnelRepositoryType) {
      self.key = key
      self.repository = repository

      baseURLComponentsResultSubject
        .map { try? $0.get() }
        .assign(to: &$baseURL)

      Task {
        let baseURLResult = await Result {
          try await self.repository.tunnel(forKey: key)
        }.unwrap(DeveloperServerError.noServer)
        self.baseURLComponentsResultSubject.send(baseURLResult)
      }
    }
  }
#endif
