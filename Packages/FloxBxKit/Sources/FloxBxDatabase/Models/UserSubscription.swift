import Fluent
import Foundation

internal final class UserSubscription: Model {
  internal enum FieldKeys {
    internal static let userID: FieldKey = "userID"
    internal static let tag: FieldKey = "tag"
  }

  internal static let schema = "UserSubscriptions"

  @ID(key: .id)
  internal var id: UUID?

  @Parent(key: FieldKeys.userID)
  internal var user: User

  @Parent(key: FieldKeys.tag)
  internal var tag: Tag

  internal init() {}
}
