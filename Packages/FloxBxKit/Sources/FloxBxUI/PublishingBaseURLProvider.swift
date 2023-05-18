#if canImport(Combine)
  import Combine
  import FloxBxRequests
  import Foundation

  protocol PublishingBaseURLProvider: BaseURLProvider {
    var baseURLComponentsPublisher: AnyPublisher<URLComponents, Never> { get }
  }
#endif
