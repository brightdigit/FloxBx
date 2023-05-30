#if canImport(Combine) && DEBUG
  import Combine
  import Foundation
  import Sublimation

  class TunnelBaseURLProvider<
    TunnelRepositoryType: TunnelRepository
  >: PublishingBaseURLProvider {
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

    let key: TunnelRepositoryType.Key
    let repository: TunnelRepositoryType

    var baseURLResult: Result<URL, Error>?

    @Published var baseURL: URL?

    let baseURLComponentsResultSubject = PassthroughSubject<Result<URL, Error>, Never>()

    var isReadyPublisher: AnyPublisher<Bool, Never> {
      $baseURL.map { $0 != nil }.eraseToAnyPublisher()
    }

    var baseURLComponents: URLComponents? {
      baseURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }
    }
  }
#endif
