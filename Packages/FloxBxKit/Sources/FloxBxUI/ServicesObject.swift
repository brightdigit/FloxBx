import Combine
import FelinePine
import FloxBxAuth
import FloxBxLogging
import FloxBxUtilities
import Foundation
import Prch
import PrchModel
import Sublimation

struct Account {
  let username: String
}

internal class ServicesObject: ObservableObject, LoggerCategorized {
  internal convenience init(error: Error? = nil) {
    let service: (any AuthorizedService)! = FloxBxService(
      host: Configuration.productionBaseURL.host() ?? Configuration.serviceName,
      accessGroup: Configuration.accessGroup,
      serviceName: Configuration.serviceName,
      urlBucketName: Configuration.Sublimation.bucketName,
      key: Configuration.Sublimation.key
    )
    self.init(service: service, error: error)
  }

  internal init(service: any AuthorizedService, isReady: Bool = false, error: Error? = nil) {
    self.service = service
    self.error = error
    self.isReady = isReady

    $service
      .combineLatest(self.service.isReadyPublisher)
      .filter { $0.1 }
      .map { $0.0 }
      .map { service in
        Future {
          try await service.verifyLogin()
        }
      }
      .switchToLatest()
      .map { !$0 }
      .replaceError(with: false)
      .receive(on: DispatchQueue.main)
      .assign(to: &$requireAuthentication)
  }

  @Published var service: any AuthorizedService
  @Published var error: Error?
  @Published var requireAuthentication = false
  @Published var isReady: Bool

  typealias LoggersType = FloxBxLogging.Loggers

  static var loggingCategory: LoggerCategory {
    .reactive
  }
}
