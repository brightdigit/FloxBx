#if canImport(Combine)
  import Combine
  import FelinePine
  import FloxBxGroupActivities
  import FloxBxLogging
  import FloxBxModels
  import FloxBxRequests
  import FloxBxUtilities
  import Foundation
  import Prch

  internal class TodoListObject: ObservableObject, LoggerCategorized {
    internal typealias LoggersType = FloxBxLogging.Loggers

    internal static var loggingCategory: FloxBxLogging.LoggerCategory {
      LoggerCategory.reactive
    }

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var updateItemCancellable: AnyCancellable!

    internal let groupActivityID: UUID?
    internal let service: any FloxBxServiceProtocol
    @Published internal private(set) var items: [TodoContentItem]
    @Published internal private(set) var isLoaded: Bool
    @Published internal private(set) var lastErrror: Error?

    private let errorSubject = PassthroughSubject<Error, Never>()
    private let actionSubject = PassthroughSubject<TodoListAction, Never>()
    private let loadSubject = PassthroughSubject<Void, Never>()

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
      }
      .catch { error in
        Just<Error?>(error)
      }

      updateItemCancellable = requestResult.map { item in
        Optional.some(item)
      }
      .catch { _ in
        Just(nil)
      }
      .compactMap { $0 }
      .receive(on: DispatchQueue.main)
      .sink { content, index in
        let item = TodoContentItem(content: content)
        if let index = index {
          self.items[index] = item
        } else {
          self.items.append(item)
        }
      }
    }

    internal func addDelta(_: TodoListDelta) {}

    internal func saveItem(_ item: TodoContentItem, onlyNew: Bool = false) {
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

      try await withThrowingTaskGroup(of: Void.self) { taskGroup in
        for id in deletedIds {
          let request = DeleteTodoItemRequest(
            itemID: id, groupActivityID: groupActivityID
          )
          taskGroup.addTask {
            _ = try await self.service.request(request)
          }
        }
        try await taskGroup.reduce(()) { partialResult, _ in
          partialResult
        }
      }

      Task { @MainActor in
        self.items.remove(atOffsets: indexSet)
      }
    }

    internal func beginDeleteItems(
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

    internal func begin() {
      loadSubject.send()
    }

    internal func addItem(_ item: TodoContentItem) {
      actionSubject.send(.append(item))
    }
  }
#endif
