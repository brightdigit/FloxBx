#if canImport(Combine)
  import Combine
  import FloxBxRequests
  import Foundation

  protocol PublishingBaseURLProvider: BaseURLProvider {
    var isReadyPublisher: AnyPublisher<Bool, Never> { get }
  }
#endif
