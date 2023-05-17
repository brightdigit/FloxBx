import Combine
import FelinePine
import FloxBxGroupActivities
import FloxBxLogging
import FloxBxModels
import FloxBxRequests
import FloxBxUtilities
import Foundation
import Prch

public protocol FloxBxServiceProtocol: ServiceProtocol where ServiceAPI == FloxBxAPI {}

enum TodoListAction: CustomStringConvertible {
  case update(CreateTodoResponseContent, at: Int)
  case append(TodoContentItem)

  var description: String {
    switch self {
    case let .update(content, at: index):
      return "update \(content) at \(index)"
    case let .append(item):
      return "append \(item)"
    }
  }
}

class TodoListObject: ObservableObject, LoggerCategorized {
  typealias LoggersType = FloxBxLogging.Loggers

  static var loggingCategory: FloxBxLogging.LoggerCategory {
    LoggerCategory.reactive
  }

  var updateItemCancellable: AnyCancellable!

  // swiftlint:disable:next function_body_length
  internal init(
    groupActivityID: UUID?,
    service: any AuthorizedService,
    items: [TodoContentItem] = [],
    isLoaded: Bool = false,
    lastErrror: Error? = nil
  ) {
    self.groupActivityID = groupActivityID
    self.service = service
    self.items = items
    self.isLoaded = isLoaded
    self.lastErrror = lastErrror

    let loadResult = loadSubject.flatMap {
      Future {
        try await self.service.request(
          GetTodoListRequest(groupActivityID: self.groupActivityID)
        )
      }
    }
    .share()

    let errorLoadResult = loadResult.map { _ in nil }.catch(Just<Error?>.init)

    let listLoaded = loadResult
      .map(Optional.some)
      .catch { _ in Just(nil) }
      .compactMap { $0 }
      .map {
        $0.map(TodoContentItem.init(content:))
      }
      .share()

    listLoaded.receive(on: DispatchQueue.main).assign(to: &$items)
    listLoaded.map { _ in true }.receive(on: DispatchQueue.main).assign(to: &$isLoaded)

    let requestResult = actionSubject.flatMap { action in
      Self.logger.debug("Received Action: \(action)")
      let request: UpsertTodoRequest
      let index: Int?
      switch action {
      case let .update(content, at: location):
        request = .init(
          groupActivityID: self.groupActivityID,
          itemID: content.id,
          body: .init(title: content.title, tags: content.tags)
        )
        index = location

      case let .append(item):
        request = .init(
          groupActivityID: self.groupActivityID,
          itemID: item.serverID,
          body: .init(title: item.title, tags: item.tags)
        )
        index = nil
      }
      let publisher = Future {
        try await self.service.request(request)
      }

      return publisher.map {
        ($0, index)
      }
    }

    let upsertErrorPublisher = requestResult.map { _ in
      nil
    }.catch { error in
      Just<Error?>(error)
    }

    updateItemCancellable = requestResult.map { item in
      Optional.some(item)
    }
    .catch { _ in
      Just(nil)
    }.compactMap { $0 }.receive(on: DispatchQueue.main)
    .sink { content, index in
      let item = TodoContentItem(content: content)
      if let index = index {
        self.items[index] = item
      } else {
        self.items.append(item)
      }
    }
  }

  let groupActivityID: UUID?
  let service: any FloxBxServiceProtocol
  @Published var items: [TodoContentItem]
  @Published var isLoaded: Bool
  @Published var lastErrror: Error?

  let errorSubject = PassthroughSubject<Error, Never>()
  let actionSubject = PassthroughSubject<TodoListAction, Never>()
  let loadSubject = PassthroughSubject<Void, Never>()

  internal func addDelta(_: TodoListDelta) {}

  func saveItem(_ item: TodoContentItem, onlyNew: Bool = false) {
    guard let index = items.firstIndex(where: { $0.id == item.id }) else {
      return
    }

    guard !(item.isSaved && onlyNew) else {
      return
    }

    let content = CreateTodoRequestContent(title: item.title, tags: item.tags)
    let request = UpsertTodoRequest(
      groupActivityID: groupActivityID,
      itemID: item.serverID,
      body: content
    )

    Task {
      let todoItem: CreateTodoResponseContent
      do {
        todoItem = try await service.request(request)
      } catch {
        self.errorSubject.send(error)
        return
      }
      self.actionSubject.send(.update(todoItem, at: index))
    }

//    service.beginRequest(request) { todoItemResult in
//      switch todoItemResult {
//      case let .success(todoItem):
//
//        DispatchQueue.main.async {
//          // self.addDelta(.upsert(todoItem.id, content))
//
//          self.items[index] = .init(content: todoItem)
//        }
//
//      case let .failure(error):
    // break
//        //self.onError(error)
//      }
//    }
  }

  private func deleteItems(
    atIndexSet indexSet: IndexSet
  ) async throws {
    let savedIndexSet = indexSet.filteredIndexSet(includeInteger: { items[$0].isSaved })

    let deletedIds = Set(savedIndexSet.compactMap {
      items[$0].serverID
    })

    guard !deletedIds.isEmpty else {
      return
    }

    // addDelta(.remove(deletedIds))
    // addDelta(.remove(Array(deletedIds)))

    // let group = DispatchGroup()

    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
      for id in deletedIds {
        // group.enter()
        let request = DeleteTodoItemRequest(
          itemID: id, groupActivityID: groupActivityID
        )
        taskGroup.addTask {
          _ = try await self.service.request(request)
        }
//        service.beginRequest(request) { error in
//          errors[index] = error
//          group.leave()
//        }
      }
      try await taskGroup.reduce(()) { partialResult, _ in
        partialResult
      }
    }

    Task { @MainActor in
      self.items.remove(atOffsets: indexSet)
    }

    // var errors = [Error?].init(repeating: nil, count: deletedIds.count)

//    group.notify(queue: .main) {
//      completed(errors.compactMap { $0 }.last)
//    }
  }

  func beginDeleteItems(
    atIndexSet indexSet: IndexSet
  ) {
    Task {
      do {
        try await self.deleteItems(atIndexSet: indexSet)
      } catch {
        self.errorSubject.send(error)
      }
    }
  }

  func begin() {
    loadSubject.send()
  }

//
//  func logout () {
//
//  }

  func addItem(_ item: TodoContentItem) {
    actionSubject.send(.append(item))
  }

//  func requestSharing() {
//
//  }
}
