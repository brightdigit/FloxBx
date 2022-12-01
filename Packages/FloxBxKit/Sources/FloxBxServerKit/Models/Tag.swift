import Fluent
import Vapor

internal final class Tag: Model, Content {
  internal enum FieldKeys {
    internal static let name: FieldKey = "name"
  }

  internal static let schema = "Tags"

  @ID(custom: FieldKeys.name, generatedBy: .user)
  internal var id: String?
  
  @Siblings(through: TodoTag.self, from: \.$tag, to: \.$todo)
  internal var tags: [Todo]
//  @ID(key: .id)
//  internal var id: UUID?
//
//  @Field(key: "title")
//  internal var title: String
//
//  @Parent(key: FieldKeys.userID)
//  internal var user: User

  internal init() {}

//  internal init(title: String, userID: UUID? = nil, id: UUID? = nil) {
//    self.id = id
//    self.title = title
//    if let userID = userID {
//      $user.id = userID
//    }
//  }
}
