import Foundation



public struct UpsertTodoRequest: ClientBodySuccessRequest {
  internal init(destination: UpsertTodoRequest.Destination, body: UpsertTodoRequest.BodyType) {
    self.destination = destination
    self.body = body
  }
  
  internal init(itemID: UUID?, body: UpsertTodoRequest.BodyType) {
    let destination : Destination
    
    if let itemID = itemID {
      destination = .itemID(itemID)
    } else {
      destination = .create
    }
    self.init(destination: destination, body: body)
  }
  
  public enum Destination {
    case userID(UUID)
    case itemID(UUID)
    case create
  }
  public let destination: Destination
  public let body: BodyType

  public typealias SuccessType = CreateTodoResponseContent

  public typealias BodyType = CreateTodoRequestContent

  public static var requiresCredentials: Bool {
    true
  }

  public static let basePath = "api/v1/todos"
  public var path: String {
    switch destination {
    case .userID(let userID):
      return "api/v1/users/\(userID)/todos"
    case .itemID(let itemID):
      return [Self.basePath, itemID.uuidString].joined(separator: "/")
    case .create:
      return Self.basePath
    }
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    switch self.destination {
    case .itemID: return .PUT
    default: return .POST
    }
  }

  public var headers: [String: String] {
    [:]
  }
}
