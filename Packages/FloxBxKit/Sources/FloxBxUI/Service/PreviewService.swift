#if canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxModels
  import FloxBxRequests
  import Foundation
  import PrchModel

  internal struct PreviewService: FloxBxServiceProtocol, AuthorizedService {
    internal func save(credentials _: Credentials) throws {
      fatalError("This service is for previews only")
    }

    internal func resetCredentials() throws {
      fatalError("This service is for previews only")
    }

    internal func fetchCredentials() async throws -> Credentials? {
      fatalError("This service is for previews only")
    }

    internal var isReadyPublisher: AnyPublisher<Bool, Never> {
      Just(true).eraseToAnyPublisher()
    }

    internal func request<RequestType>(_: RequestType)
    async throws -> RequestType.SuccessType.DecodableType
      where
      RequestType: PrchModel.ServiceCall,
      FloxBxRequests.FloxBxAPI == RequestType.ServiceAPI {
      // swiftlint:disable:next force_cast
      todoItems as! RequestType.SuccessType.DecodableType
    }

    internal init(todoItems: [CreateTodoResponseContent] = []) {
      self.todoItems = todoItems
    }

    private let todoItems: [CreateTodoResponseContent]
  }
#endif
