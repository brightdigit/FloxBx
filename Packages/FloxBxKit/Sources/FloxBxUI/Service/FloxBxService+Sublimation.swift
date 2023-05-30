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

  #if DEBUG
    extension FloxBxService {
      public convenience init(
        host: String = Configuration.productionBaseURL.host ?? Configuration.serviceName,
        accessGroup: String = Configuration.accessGroup,
        serviceName: String = Configuration.serviceName,
        urlBucketName: String = Configuration.Sublimation.bucketName,
        key: String = Configuration.Sublimation.key,
        session: URLSession = .shared
      ) where
        SessionType == URLSession {
        let tunnelRepo = TunnelBaseURLProvider(
          key: key,
          repository: KVdbTunnelRepository<String>(
            client: URLSessionClient(session: .ephemeral()),
            bucketName: urlBucketName
          )
        )
        self.init(baseURLProvider: tunnelRepo, host: host, accessGroup: accessGroup, serviceName: serviceName, session: session)
      }
    }
  #endif
#endif
