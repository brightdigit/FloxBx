#if canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxRequests
  import Foundation
  import Prch
  import PrchModel
  import StealthyStash

  class FloxBxService<SessionType: Session>: Service
    where SessionType.ResponseType.DataType == Data, SessionType.RequestDataType == Data {
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

    let isReadyPublisher: AnyPublisher<Bool, Never>

    var api: FloxBxRequests.FloxBxAPI

    var session: SessionType

    typealias ServiceAPI = FloxBxAPI

    var authorizationManager: any AuthorizationManager<SessionType.AuthorizationType> {
      repository
    }

    let repository: any StealthyManager<SessionType.AuthorizationType>
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
