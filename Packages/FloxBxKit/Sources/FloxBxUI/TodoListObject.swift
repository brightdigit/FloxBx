//
//  File.swift
//  
//
//  Created by Leo Dion on 2/3/23.
//

import Foundation
import Combine
import FloxBxUtilities
import FloxBxNetworking
import FloxBxModels
import FloxBxRequests
import FloxBxGroupActivities

enum TodoListAction {
  case update(CreateTodoResponseContent, at: Int)
  case append(TodoContentItem)
}

class TodoListObject : ObservableObject {
  var updateItemCancellable : AnyCancellable!
  internal init(groupActivityID: UUID?, service: any AuthorizedService, items: [TodoContentItem] = [], isLoaded: Bool = false, lastErrror: Error? = nil) {
    self.groupActivityID = groupActivityID
    self.service = service
    self.items = items
    self.isLoaded = isLoaded
    self.lastErrror = lastErrror
    
    //assert(((try? service.fetchCredentials()) != nil))
    
    let loadResult = self.loadSubject.map {
      Future{
        try await self.service.request(GetTodoListRequest(groupActivityID: self.groupActivityID))
      }
    }.switchToLatest().share()
    
    let errorLoadResult = loadResult.map{_ in return nil}.catch(Just<Error?>.init)
    
    let listLoaded = loadResult.map(Optional.some).catch{_ in Just(nil)}.compactMap{$0}.map{
      $0.map(TodoContentItem.init(content:))
    }.share()
    
    listLoaded.receive(on: DispatchQueue.main).assign(to: &self.$items)
    listLoaded.map{_ in true}.receive(on: DispatchQueue.main).assign(to: &self.$isLoaded)
    
   let requestResult = self.actionSubject.map { action in
      let request : UpsertTodoRequest
     let index : Int?
      switch action {
      case .update(let content, at: let location):
        request = .init(groupActivityID: self.groupActivityID, itemID: content.id, body: .init(title: content.title, tags: content.tags))
        index = location
      case .append(let item):
        request = .init(groupActivityID: self.groupActivityID, itemID: item.serverID, body: .init(title: item.title, tags: item.tags))
        index = nil
      }
      let publisher = Future{
        try await self.service.request(request)
      }
     
     return publisher.map {
       ($0, index)
     }
   }.switchToLatest()
    
    let upsertErrorPublisher = requestResult.map { _ in
      return nil
    }.catch { error in
      return Just<Error?>(error)
    }
    
    self.updateItemCancellable =     requestResult.map{item in
      return Optional.some(item)
    }
      .catch { error in
      return Just(nil)
      }.compactMap{$0}.receive(on: DispatchQueue.main)
      .sink { (content, index) in
        let item = TodoContentItem(content: content)
        if let index = index {
          self.items[index] = item
        } else {
          self.items.append(item)
        }
      }
    
    //Publishers.CombineLatest(upsertErrorPublisher, errorLoadResult).eraseToAnyPublisher().sink
  }
  
  let groupActivityID : UUID?
  let service: any Service
  @Published var items : [TodoContentItem]
  @Published var isLoaded : Bool
  @Published var lastErrror : Error?
  
  let errorSubject = PassthroughSubject<Error, Never>()
  let actionSubject = PassthroughSubject<TodoListAction, Never>()
  let loadSubject = PassthroughSubject<Void, Never>()
  
  
    internal func addDelta(_ delta: TodoListDelta) {
    }
  
  func saveItem(_ item: TodoContentItem, onlyNew: Bool = false) {
    guard let index = items.firstIndex(where: { $0.id == item.id }) else {
      return
    }

    guard !(item.isSaved && onlyNew) else {
      return
    }

    let content = CreateTodoRequestContent(title: item.title, tags: item.tags)
    let request = UpsertTodoRequest(
      groupActivityID: self.groupActivityID,
      itemID: item.serverID,
      body: content
    )
    
    Task {
      let todoItem : CreateTodoResponseContent
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
//break
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

    addDelta(.remove(deletedIds))
    // addDelta(.remove(Array(deletedIds)))

    //let group = DispatchGroup()

    try await withThrowingTaskGroup(of: Void.self) { taskGroup in
      for id in deletedIds {
        //group.enter()
        let request = DeleteTodoItemRequest(
          itemID: id, groupActivityID: groupActivityID
        )
        taskGroup.addTask {
          try await self.service.request(request)
        }
//        service.beginRequest(request) { error in
//          errors[index] = error
//          group.leave()
//        }
      }
      try await taskGroup.reduce(()) { partialResult, _ in
        return partialResult
      }
    }
    //var errors = [Error?].init(repeating: nil, count: deletedIds.count)

//    group.notify(queue: .main) {
//      completed(errors.compactMap { $0 }.last)
//    }
  }
  
  func beginDeleteItems(
    atIndexSet indexSet: IndexSet
  ) {
    Task{
      do {
        try await self.deleteItems(atIndexSet: indexSet)
      } catch {
        self.errorSubject.send(error)
      }
    }
  }
  
  func begin () {
    self.loadSubject.send()
  }
//
//  func logout () {
//
//  }
  
  func addItem(_ item: TodoContentItem) {
    self.actionSubject.send(.append(item))
  }
  
//  func requestSharing() {
//    
//  }
}
