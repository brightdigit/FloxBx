#if canImport(Combine)

  import Combine
  import FloxBxRequests
  import Foundation

  extension StaticBaseURLProvider: PublishingBaseURLProvider {
    internal var isReadyPublisher: AnyPublisher<Bool, Never> {
      Just(true).eraseToAnyPublisher()
    }
  }
#endif
