import Foundation
import PrchModel
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct DeleteTodoItemRequest: ServiceCall {
  public typealias SuccessType = Empty

  public typealias BodyType = Empty

  public typealias ServiceAPI = FloxBxAPI

  public static var requiresCredentials: Bool {
    true
  }

  private let groupActivityID: UUID?
  private let itemID: UUID

  public var path: String {
    var path = "api/v1/"
    if let groupActivityID = groupActivityID {
      path.append("group-sessions/\(groupActivityID)/")
    }
    path.append("todos/\(itemID)")

    return path
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    .DELETE
  }

  public var headers: [String: String] {
    [:]
  }

  public init(itemID: UUID, groupActivityID: UUID? = nil) {
    self.groupActivityID = groupActivityID
    self.itemID = itemID
  }
}
