import Foundation

public struct UpsertTodoRequest: ClientBodySuccessRequest {
  public let itemID: UUID?
  public let body: BodyType

  public typealias SuccessType = CreateTodoResponseContent

  public typealias BodyType = CreateTodoRequestContent

  public static var requiresCredentials: Bool {
    true
  }

  public static let basePath = "api/v1/todos"
  public var path: String {
    if let itemID = itemID {
      return [Self.basePath, itemID.uuidString].joined(separator: "/")
    } else {
      return Self.basePath
    }
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    itemID == nil ? .POST : .PUT
  }

  public var headers: [String: String] {
    [:]
  }
}
