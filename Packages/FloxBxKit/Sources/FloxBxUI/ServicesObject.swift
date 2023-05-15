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
    let service: (any AuthorizedService)! = nil
    #error("Create a service")
    self.init(service: service, error: error)
  }

  internal init(service: any AuthorizedService, isReady: Bool = false, error: Error? = nil) {
    self.service = service
    self.error = error
    self.isReady = isReady

    $service
      .compactMap { $0 }
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
