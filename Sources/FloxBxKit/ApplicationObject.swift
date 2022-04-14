public enum Configuration {
  public static let dsn = "https://d2a8d5241ccf44bba597074b56eb692d@o919385.ingest.sentry.io/5868822"
}

#if canImport(Combine) && canImport(SwiftUI)
  import Canary
  import Combine
  import SwiftUI

  #if canImport(GroupActivities)
    import GroupActivities
  #endif

  // @available(iOS 15, *)
  // public struct FloxBxActivity : GroupActivity  {
//  internal init(username: String) {
//    var metadata = GroupActivityMetadata()
//    metadata.title = "\(username) FloxBx"
//    metadata.type = .generic
//    self.metadata = metadata
//  }
//
//
//  public let metadata : GroupActivityMetadata
//
//
//
  // }

  public class ApplicationObject: ObservableObject {
    // @available(iOS 15, *)
    // @State var groupSession: GroupSession<FloxBxActivity>?
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

    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    static let server = "floxbx.work"
    public init(items _: [TodoContentItem] = []) {
      requiresAuthentication = true
      let authenticated = $token.map { $0 == nil }
      authenticated.receive(on: DispatchQueue.main).assign(to: &$requiresAuthentication)
      $token.share().compactMap { $0 }.flatMap { _ in
        Future { closure in
          self.service.beginRequest(GetTodoListRequest()) { result in
            closure(result)
          }
        }
      }.map { content in
        content.map(TodoContentItem.init)
      }
      .replaceError(with: []).receive(on: DispatchQueue.main).assign(to: &$items)

      try! sentry.start(withOptions: .init(dsn: Configuration.dsn))
    }

    @available(*, deprecated)
    public static func url(withPath path: String) -> URL {
      baseURL.appendingPathComponent(path)
    }

    public func saveItem(_ item: TodoContentItem, onlyNew: Bool = false) {
      guard let index = items.firstIndex(where: { $0.id == item.id }) else {
        return
      }

      guard !(item.isSaved && onlyNew) else {
        return
      }

      let request = UpsertTodoRequest(itemID: item.serverID, body: .init(title: item.title))

      service.beginRequest(request) { todoItemResult in
        switch todoItemResult {
        case let .success(todoItem):

          DispatchQueue.main.async {
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

      let deletedIds = Set(savedIndexSet.map {
        items[$0].id
      })
//
      guard !deletedIds.isEmpty else {
        DispatchQueue.main.async {
          completed(nil)
        }
        return
      }

      let group = DispatchGroup()

      var errors = [Error?].init(repeating: nil, count: deletedIds.count)
      for (index, id) in deletedIds.enumerated() {
        group.enter()
        let request = DeleteTodoItemRequest(itemID: id)
        service.beginRequest(request) { error in
          errors[index] = error
          group.leave()
        }
//        URLSession.shared.dataTask(with: request) { _, _, error in
//          errors[index] = error
//          group.leave()
//        }.resume()
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

    public func beginSignIn(withCredentials credentials: Credentials) {
      let createToken = credentials.token == nil
      if createToken {
        service.beginRequest(SignInCreateRequest(body: .init(emailAddress: credentials.username, password: credentials.password))) { _ in
        }
      } else {
        service.beginRequest(SignInRefreshRequest()) { result in
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
            try? self.service.save(credentials: newCreds)
            DispatchQueue.main.async {
              self.username = newCreds.username
              self.token = newCreds.token
            }

          case (.none, true):
            break
          }
        }
      }
    }
  }
#endif
