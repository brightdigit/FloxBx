#if canImport(Security) && canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxRequests
  import FloxBxUtilities
  import Foundation
  import Prch
  import PrchModel
  import StealthyStash
  import Sublimation

  extension FloxBxService {
    public convenience init(
      baseURL: URL = Configuration.productionBaseURL,
      accessGroup: String = Configuration.accessGroup,
      serviceName: String = Configuration.serviceName,
      session: URLSession = .shared
    ) where
      SessionType == URLSession {
      guard let baseURLComponents = URLComponents(
        url: baseURL,
        resolvingAgainstBaseURL: false
      ) else {
        fatalError("Unable to acquire base URL")
      }

      let host = baseURLComponents.host ?? baseURL.host ?? Configuration.serviceName
      let provider = StaticBaseURLProvider(baseURLComponents: baseURLComponents)

      self.init(
        baseURLProvider: provider,
        host: host,
        accessGroup: accessGroup,
        serviceName: serviceName,
        session: session
      )
    }
  }
#endif
