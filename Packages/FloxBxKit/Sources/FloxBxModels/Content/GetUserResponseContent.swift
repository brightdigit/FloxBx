import Foundation

public struct GetUserResponseContent: Codable {
  let id: UUID
  let username: String
  public init(id: UUID, username: String) {
    self.id = id
    self.username = username
  }
}
