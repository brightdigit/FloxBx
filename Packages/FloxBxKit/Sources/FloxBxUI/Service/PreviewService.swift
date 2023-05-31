#if canImport(Combine)
  import Combine
  import FloxBxAuth
  import FloxBxModels
  import FloxBxRequests
  import Foundation
  import PrchModel

  struct PreviewService: FloxBxServiceProtocol, AuthorizedService {
    internal init(todoItems: [CreateTodoResponseContent] = []) {
      self.todoItems = todoItems
    }

    let todoItems: [CreateTodoResponseContent]
    func save(credentials _: Credentials) throws {
      fatalError()
    }

    func resetCredentials() throws {
      fatalError()
    }

    func fetchCredentials() async throws -> Credentials? {
      fatalError()
    }

    var isReadyPublisher: AnyPublisher<Bool, Never> {
      Just(true).eraseToAnyPublisher()
    }

    func request<RequestType>(_: RequestType)
    async throws -> RequestType.SuccessType.DecodableType
      where
      RequestType: PrchModel.ServiceCall,
      FloxBxRequests.FloxBxAPI == RequestType.ServiceAPI {
      // swiftlint:disable:next force_cast
      todoItems as! RequestType.SuccessType.DecodableType
    }
  }
#endif
