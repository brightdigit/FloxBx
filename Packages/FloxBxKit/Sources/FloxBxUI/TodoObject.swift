import Combine
import FloxBxModels
import FloxBxRequests
import Foundation
import Prch

class TodoObject: ObservableObject {
  let saveTrigger = PassthroughSubject<Void, Never>()
  let groupActivityID: UUID?
  let service: any ServiceProtocol
  @Published var text: String
  @Published var item: TodoContentItem
  @Published var lastError: Error?

  var isSaved: Bool {
    false
  }

  init(item: TodoContentItem, service: any ServiceProtocol, groupActivityID: UUID?) {
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
      .map { request -> Future<CreateTodoResponseContent, Error> in
        Future<CreateTodoResponseContent, Error> {
          try await self.service.request(request)
        }
      }
      .switchToLatest()
      .map(TodoContentItem.init(content:))
      .map(Result.success)
      .catch { error in
        Just(.failure(error))
      }.share()

    savedItemPublisher
      .compactMap { try? $0.get() }
      .receive(on: DispatchQueue.main)
      .assign(to: &$item)

    savedItemPublisher.map { result in
      guard case let .failure(error) = result else {
        return nil
      }

      return error
    }.receive(on: DispatchQueue.main)
      .assign(to: &$lastError)
  }

  func beginSave() {
    saveTrigger.send()
    // self.service.request(<#T##request: ClientRequest##ClientRequest#>)
  }
}
