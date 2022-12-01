import Fluent

public final class Tag: Model {
  internal enum FieldKeys {
    internal static let name: FieldKey = "name"
  }

  public static let schema = "Tags"

  @ID(custom: FieldKeys.name, generatedBy: .user)
  public var id: String?

  @Siblings(through: TodoTag.self, from: \.$tag, to: \.$todo)
  public var tags: [Todo]

  @Siblings(through: UserSubscription.self, from: \.$tag, to: \.$user)
  public var subscribers: [User]
//  @ID(key: .id)
//  internal var id: UUID?
//
//  @Field(key: "title")
//  internal var title: String
//
//  @Parent(key: FieldKeys.userID)
//  internal var user: User

  public init() {}

//  internal init(title: String, userID: UUID? = nil, id: UUID? = nil) {
//    self.id = id
//    self.title = title
//    if let userID = userID {
//      $user.id = userID
//    }
//  }
}
