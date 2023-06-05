#if canImport(Combine)
  import Combine
  import FloxBxRequests
  import Foundation

  internal protocol PublishingBaseURLProvider: BaseURLProvider {
    var isReadyPublisher: AnyPublisher<Bool, Never> { get }
  }
#endif
