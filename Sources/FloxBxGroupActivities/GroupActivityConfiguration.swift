import Foundation

public struct GroupActivityConfiguration {
  public init(groupSessionID: UUID, username: String) {
    self.groupSessionID = groupSessionID
    self.username = username
  }

  let groupSessionID: UUID
  let username: String
}
