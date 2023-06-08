#if canImport(Combine)
  import Combine
  import FloxBxModels
  import FloxBxRequests
  import Foundation
  import Prch

  internal class TodoObject: ObservableObject {
    private let saveTrigger = PassthroughSubject<Void, Never>()
    private let groupActivityID: UUID?
    private let service: any FloxBxServiceProtocol
    @Published internal var text: String
    @Published internal private(set) var item: TodoContentItem
    @Published internal private(set) var lastError: Error?

    internal var isSaved: Bool {
      item.isSaved
    }

    internal init(
      item: TodoContentItem,
      service: any FloxBxServiceProtocol,
      groupActivityID: UUID?
    ) {
      text = item.text
      self.item = item
      self.groupActivityID = groupActivityID
      self.service = service

      let savedItemPublisher = saveTrigger
        .map { _ -> UpsertTodoRequest in
          let content = CreateTodoRequestContent(text: self.text)
          return UpsertTodoRequest(
            groupActivityID: groupActivityID,
            itemID: self.item.serverID,
            body: content
          )
        }
        .flatMap { request -> Future<CreateTodoResponseContent, Error> in
          Future<CreateTodoResponseContent, Error> {
            try await self.service.request(request)
          }
        }
        .map(TodoContentItem.init(content:))
        .map(Result.success)
        .catch { error in
          Just(.failure(error))
        }
        .share()

      savedItemPublisher
        .compactMap { try? $0.get() }
        .receive(on: DispatchQueue.main)
        .assign(to: &$item)

      savedItemPublisher.map { result in
        guard case let .failure(error) = result else {
          return nil
        }

        return error
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$lastError)
    }

    internal func beginSave() {
      saveTrigger.send()
    }
  }
#endif
