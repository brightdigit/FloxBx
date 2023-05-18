#if canImport(Security) && canImport(Combine)
  import FloxBxAuth
  import FloxBxRequests
  import Foundation
  import Prch
  import PrchModel
  import StealthyStash
  import Sublimation

  extension FloxBxService {
    public convenience init(
      host: String,
      accessGroup: String,
      serviceName: String,
      urlBucketName: String,
      key: String,
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
      let repository = KeychainRepository(
        defaultServiceName: serviceName,
        defaultServerName: host,
        defaultAccessGroup: accessGroup
      )

      let api = FloxBxAPI(baseURLProvider: tunnelRepo)
      self.init(
        api: api,
        session: session,
        repository: CredentialsContainer(repository: repository),
        isReadyPublisher: tunnelRepo.$baseURL.map { $0 != nil }.eraseToAnyPublisher()
      )
    }
  }
#endif
