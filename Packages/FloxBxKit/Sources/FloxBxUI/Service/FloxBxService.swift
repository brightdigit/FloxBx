#if canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxRequests
  import Foundation
  import Prch
  import PrchModel
  import StealthyStash

  internal class FloxBxService<SessionType: Session>: Service
    where SessionType.ResponseType.DataType == Data, SessionType.RequestDataType == Data {
    internal typealias ServiceAPI = FloxBxAPI

    internal let isReadyPublisher: AnyPublisher<Bool, Never>

    internal var api: FloxBxRequests.FloxBxAPI

    internal var session: SessionType

    internal var authorizationManager: any AuthorizationManager<
      SessionType.AuthorizationType
    > {
      repository
    }

    internal let repository: any StealthyManager<SessionType.AuthorizationType>

    internal init(
      api: FloxBxAPI,
      session: SessionType,
      repository: any StealthyManager<SessionType.AuthorizationType>,
      isReadyPublisher: AnyPublisher<Bool, Never>
    ) {
      self.api = api
      self.session = session
      self.repository = repository
      self.isReadyPublisher = isReadyPublisher
    }
  }

  extension FloxBxService {
    internal convenience init(
      baseURLProvider: PublishingBaseURLProvider,
      host: String,
      accessGroup: String,
      serviceName: String,
      session: URLSession = .shared
    ) where SessionType == URLSession {
      let repository = KeychainRepository(
        defaultServiceName: serviceName,
        defaultServerName: host,
        defaultAccessGroup: accessGroup
      )
      let api = FloxBxAPI(baseURLProvider: baseURLProvider)
      self.init(
        api: api,
        session: session,
        repository: CredentialsContainer(repository: repository),
        isReadyPublisher: baseURLProvider.isReadyPublisher
      )
    }
  }
#endif
