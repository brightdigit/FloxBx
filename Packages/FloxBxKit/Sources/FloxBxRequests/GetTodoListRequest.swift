import FloxBxModels
import Foundation
import PrchModel

public struct GetTodoListRequest: ServiceCall {
  public typealias SuccessType = [CreateTodoResponseContent]

  public static var requiresCredentials: Bool {
    true
  }

  private let groupActivityID: UUID?

  public var path: String {
    var path = "api/v1/"
    if let groupActivityID = groupActivityID {
      path.append("group-sessions/\(groupActivityID)/")
    }
    path.append("todos")

    return path
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    .GET
  }

  public var headers: [String: String] {
    [:]
  }

  public init(groupActivityID: UUID? = nil) {
    self.groupActivityID = groupActivityID
  }
}
