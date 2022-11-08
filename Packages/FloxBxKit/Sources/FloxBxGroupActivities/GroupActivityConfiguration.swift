import Foundation

public struct GroupActivityConfiguration {
  let groupActivityID: UUID
  let username: String
  public init(groupActivityID: UUID, username: String) {
    self.groupActivityID = groupActivityID
    self.username = username
  }
}
