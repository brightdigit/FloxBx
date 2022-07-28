import FloxBxModels
import FloxBxNetworking
import FloxBxAuth
import FloxBxGroupActivities

#if canImport(Combine) && canImport(SwiftUI)
  import Canary
  import Combine
  import SwiftUI



public class ApplicationObject: ObservableObject {
  @Published var shareplayObject = SharePlayObject()
  
  var cancellables = [AnyCancellable]()
    
    func addDelta(_ delta: TodoListDelta) {
//        DispatchQueue.main.async {
//            self.listDeltas.append(delta)
//        }

      self.shareplayObject.send([delta])
//        if #available(iOS 15, macOS 12, *) {
//            if let messenger = self.messenger {
//                Task {
//                    try? await messenger.send([delta])
//                }
//            }
//        }
    }
    
    @Published public var requiresAuthentication: Bool
    @Published var latestError: Error?
    @Published var token: String?
    @Published var username: String?
    @Published var items = [TodoContentItem]()
    let service: Service = ServiceImpl(host: ProcessInfo.processInfo.environment["HOST_NAME"]!, headers: ["Content-Type": "application/json; charset=utf-8"])

    let sentry = CanaryClient()

    static let baseURL: URL = {
      var components = URLComponents()
      components.host = ProcessInfo.processInfo.environment["HOST_NAME"]
      components.scheme = "https"
      return components.url!
    }()
    
//    var groupSessionID : UUID? {
//      return self.shareplayObject.sessionID
////#if canImport(GroupActivities)
////      if #available(macOS 12, iOS 15, *) {
////          return self.groupSession?.activity.id
////      } else {
////        return nil
////      }
////      #else
////      return nil
////      #endif
//    }

    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    //static let server = "floxbx.work"
    public init(_: [TodoContentItem] = []) {
      //self.shareplayObject = SharePlayObject()
      requiresAuthentication = true
      let authenticated = $token.map { $0 == nil }
      authenticated.receive(on: DispatchQueue.main).assign(to: &$requiresAuthentication)
      
      
      let groupSessionIDPub = self.shareplayObject.$groupSessionID
      
      $token.share().compactMap { $0 }.combineLatest(groupSessionIDPub).map(\.1).flatMap { groupSessionID in
        Future { closure in
          self.service.beginRequest(GetTodoListRequest(groupSessionID: groupSessionID)) { result in
            closure(result)
          }
        }
      }.map { content in
        content.map(TodoContentItem.init)
      }
      .replaceError(with: []).receive(on: DispatchQueue.main).assign(to: &$items)
      if #available(iOS 15, macOS 12, *) {
#if canImport(GroupActivities)
        self.shareplayObject.startSharingPublisher.sink(receiveValue: self.startSharing).store(in: &self.cancellables)
        self.shareplayObject.messagePublisher.sink(receiveValue: self.handle(_:)).store(in: &self.cancellables)
#endif
      } else {
        // Fallback on earlier versions
      }
      try! sentry.start(withOptions: .init(dsn: Configuration.dsn))
    }

    public func saveItem(_ item: TodoContentItem, onlyNew: Bool = false) {
      guard let index = items.firstIndex(where: { $0.id == item.id }) else {
        return
      }

      guard !(item.isSaved && onlyNew) else {
        return
      }

      
      let content = CreateTodoRequestContent(title: item.title)
      let request = UpsertTodoRequest(groupSessionID: self.shareplayObject.groupSessionID, itemID: item.serverID, body: content)


      
      service.beginRequest(request) { todoItemResult in
        switch todoItemResult {
        case let .success(todoItem):

          DispatchQueue.main.async {
#if canImport(GroupActivities)
            
            self.addDelta(.upsert(todoItem.id, content))
      #endif
            self.items[index] = .init(content: todoItem)
          }

        case let .failure(error):

          DispatchQueue.main.async {
            self.latestError = error
          }
        }
      }
    }

    public func begin() {
      let credentials: Credentials?
      let error: Error?

      do {
        credentials = try service.fetchCredentials()
        error = nil
      } catch let caughtError {
        error = caughtError
        credentials = nil
      }

      latestError = latestError ?? error

      if let credentials = credentials {
        beginSignIn(withCredentials: credentials)
      } else {
        DispatchQueue.main.async {
          self.requiresAuthentication = true
        }
      }
    }

    public func beginDeleteItems(atIndexSet indexSet: IndexSet, _ completed: @escaping (Error?) -> Void) {
      let savedIndexSet = indexSet.filteredIndexSet(includeInteger: { items[$0].isSaved })

      let deletedIds = Set(savedIndexSet.compactMap {
        items[$0].serverID
      })
      
      
//
      guard !deletedIds.isEmpty else {
        DispatchQueue.main.async {
          completed(nil)
        }
        return
      }

      #if canImport(GroupActivities)
      self.addDelta(.remove(Array(deletedIds)))
      #endif
      let group = DispatchGroup()

      var errors = [Error?].init(repeating: nil, count: deletedIds.count)
      for (index, id) in deletedIds.enumerated() {
        group.enter()
        let request = DeleteTodoItemRequest(groupSessionID: self.shareplayObject.groupSessionID, itemID: id)
        service.beginRequest(request) { error in
          errors[index] = error
          group.leave()
        }
      }
      group.notify(queue: .main) {
        completed(errors.compactMap { $0 }.last)
      }
    }

    public func deleteItems(atIndexSet indexSet: IndexSet) {
      beginDeleteItems(atIndexSet: indexSet) { error in
        self.items.remove(atOffsets: indexSet)
        self.latestError = error
      }
    }

    public func beginSignup(withCredentials credentials: Credentials) {
      service.beginRequest(SignUpRequest(body: .init(emailAddress: credentials.username, password: credentials.password))) { result in
        let newCredentialsResult = result.map { content in
          credentials.withToken(content.token)
        }.tryMap { creds -> Credentials in
          try self.service.save(credentials: creds)
          return creds
        }

        switch newCredentialsResult {
        case let .failure(error):
          DispatchQueue.main.async {
            self.latestError = error
          }

        case let .success(newCreds):
          self.beginSignIn(withCredentials: newCreds)
        }
      }
    }

    fileprivate func saveCredentials(_ newCreds: Credentials) {
      try? self.service.save(credentials: newCreds)
      DispatchQueue.main.async {
        self.username = newCreds.username
        self.token = newCreds.token
      }
    }
    
    public func beginSignIn(withCredentials credentials: Credentials) {
      let createToken = credentials.token == nil
      if createToken {
        service.beginRequest(SignInCreateRequest(body: .init(emailAddress: credentials.username, password: credentials.password))) { result in
          switch result {
          case .failure(let error):
            DispatchQueue.main.async {
              self.latestError = error
            }
          case .success(let tokenContainer):
            let newCreds = credentials.withToken(tokenContainer.token)
            self.saveCredentials(newCreds)
          }
        }
      } else {
        service.beginRequest(SignInRefreshRequest()) { [self] result in
          let newCredentialsResult: Result<Credentials, Error> = result.map { response in
            credentials.withToken(response.token)
          }.flatMapError { error in
            guard !createToken else {
              return .failure(error)
            }
            return .success(credentials.withoutToken())
          }
          let newCreds: Credentials
          switch newCredentialsResult {
          case let .failure(error):
            DispatchQueue.main.async {
              self.latestError = error
            }
            return

          case let .success(credentials):
            newCreds = credentials
          }

          switch (newCreds.token, createToken) {
          case (.none, false):
            self.beginSignIn(withCredentials: newCreds)

          case (.some, _):
            self.saveCredentials(newCreds)

          case (.none, true):
            break
          }
        }
      }
    }
    
#if canImport(GroupActivities)
    @available(iOS 15, macOS 12, *)
    func startSharing() {
        Task {
            do {
              guard let username = username else {
                return
              }
        
              let groupSession = try await self.service.request(CreateGroupSessionRequest())
              _ = try await self.shareplayObject.activity(forGroupSessionWithID: groupSession.id, withUserName: username)
              //
            } catch {
                print("Failed to activate ShoppingListActivity activity: \(error)")
            }
        }
    }
    
    @available(iOS 15, macOS 12,*)
    func reset() {
        // Clear local drawing canvas.

        //listDeltas = []

        // Teardown existing groupSession.
//        messenger = nil
//        tasks.forEach { $0.cancel() }
//        tasks = []
//        subscriptions = []
//        if groupSession != nil {
//            groupSession?.leave()
//            groupSession = nil
//            startSharing()
//        }
    }
//
//    @available(iOS 15,macOS 12, *)
//    public func configureGroupSession(_ groupSession: FloxBxGroupSession) {
//
//
//      self.shareplayObject.configureGroupSession(groupSession)
////        self.groupSession = groupSession
////
////        let messenger = GroupSessionMessenger(session: groupSession)
////        self.messenger = messenger
////
////        self.groupSession?.$state
////            .sink(receiveValue: { state in
////                if case .invalidated = state {
////                    self.groupSession = nil
////                    self.reset()
////                }
////            }).store(in: &subscriptions)
////
////        self.groupSession?.$activeParticipants
////            .sink(receiveValue: { activeParticipants in
////                let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)
////
////                Task {
////                    // try? await messenger.send(CanvasMessage(strokes: self.strokes, pointCount: self.pointCount), to: .only(newParticipants))
////                    try? await messenger.send(self.listDeltas, to: .only(newParticipants))
////                }
////            }).store(in: &subscriptions)
////        let task = Task {
////            for await(message, _) in messenger.messages(of: [TodoListDelta].self) {
////                handle(message)
////            }
////        }
////        tasks.insert(task)
////
////        groupSession.join()
//    }
    func handle(_ deltas: [TodoListDelta]) {
        for delta in deltas {
            handle(delta)
        }
    }

    func handle(_ delta: TodoListDelta) {
        switch delta {
        case let .upsert(id, content):

          let index = self.items.firstIndex { item in
            item.serverID == id
          }
          if let index = index {
            DispatchQueue.main.async {
              self.items[index] = self.items[index].updatingTitle(content.title)
            }
          } else {
            DispatchQueue.main.async {
              self.items.append(.init(serverID: id, title: content.title))
            }
          }
        case let .remove(ids):
          let indicies = ids.compactMap { id in
            self.items.firstIndex{ item in
              item.serverID == id
            }
          }
          
          DispatchQueue.main.async {
            self.items.remove(atOffsets: IndexSet(indicies))
            
          }
        }
          
      self.shareplayObject.append(delta: delta)
    }
    #endif
  }
#endif
