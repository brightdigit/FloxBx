import Fluent

internal final class TodoTag: Model {
  internal enum FieldKeys {
    internal static let todoID: FieldKey = "todoID"
    internal static let tag: FieldKey = "tag"
  }

  internal static let schema = "TodoTags"
//
//  @ID(custom: FieldKeys.name, generatedBy: .user)
//  internal var id: String?
  @ID(key: .id)
  internal var id: UUID?

  @Parent(key: FieldKeys.todoID)
  var todo: Todo

  @Parent(key: FieldKeys.tag)
  var tag: Tag
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
