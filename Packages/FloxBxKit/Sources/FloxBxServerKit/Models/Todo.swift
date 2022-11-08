import Fluent
import Vapor

final class Todo: Model, Content {
  enum FieldKeys {
    static let title: FieldKey = "title"
    static let userID: FieldKey = "userID"
  }

  static let schema = "Todos"

  @ID(key: .id)
  var id: UUID?

  @Field(key: "title")
  var title: String

  @Parent(key: FieldKeys.userID)
  var user: User

  init() {}

  init(id: UUID? = nil, title: String, userID: UUID? = nil) {
    self.id = id
    self.title = title
    if let userID = userID {
      $user.id = userID
    }
  }
}
