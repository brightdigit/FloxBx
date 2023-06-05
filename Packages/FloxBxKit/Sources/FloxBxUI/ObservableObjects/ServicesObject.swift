#if canImport(Combine)
  import Combine
  import FelinePine
  import FloxBxAuth
  import FloxBxLogging
  import FloxBxUtilities
  import Foundation
  import Prch
  import PrchModel
  import Sublimation

  internal class ServicesObject: ObservableObject, LoggerCategorized {
    internal typealias LoggersType = FloxBxLogging.Loggers

    internal static var loggingCategory: LoggerCategory {
      .reactive
    }

    @Published internal private(set) var service: any AuthorizedService
    @Published internal private(set) var error: Error?
    @Published internal private(set) var requireAuthentication = false
    @Published internal private(set) var isReady: Bool

    internal convenience init(error: Error? = nil) {
      let service: any AuthorizedService
      #if DEBUG
        service = FloxBxService(
          host: Configuration.productionBaseURL.host ?? Configuration.serviceName,
          accessGroup: Configuration.accessGroup,
          serviceName: Configuration.serviceName,
          urlBucketName: Configuration.Sublimation.bucketName,
          key: Configuration.Sublimation.key
        )
      #else
        service = FloxBxService(
          baseURL: Configuration.productionBaseURL,
          accessGroup: Configuration.accessGroup,
          serviceName: Configuration.serviceName
        )
      #endif
      self.init(service: service, error: error)
    }

    internal init(
      service: any AuthorizedService,
      isReady: Bool = false,
      error: Error? = nil
    ) {
      self.service = service
      self.error = error
      self.isReady = isReady

      self.service.isReadyPublisher.receive(on: DispatchQueue.main).assign(to: &$isReady)

      // swiftlint - false positive
      // swiftlint:disable:next array_init
      $service
        .combineLatest(self.service.isReadyPublisher)
        .filter { $0.1 }
        .map { $0.0 }
        .flatMap { service in
          Future {
            try await service.verifyLogin()
          }
        }
        .map { !$0 }
        .replaceError(with: false)
        .receive(on: DispatchQueue.main)
        .assign(to: &$requireAuthentication)
    }
  }
#endif
