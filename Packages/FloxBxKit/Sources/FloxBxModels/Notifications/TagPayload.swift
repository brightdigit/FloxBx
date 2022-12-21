import Foundation

public struct TagPayload: Codable, NotificationContent {
  public init(action: TagPayload.Action, name: String) {
    self.name = name
    self.action = action
  }

  public let name: String
  public let action: Action

  public enum Action: String, Codable {
    case added
    case removed
  }

  public var title: String {
    switch action {
    case .added:
      return "New Todo Item tagged #\(name)"
    case .removed:

      return "Todo Item tagged #\(name) Removed"
    }
  }
}
