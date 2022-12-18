import Fluent

internal final class TodoTag: Model {
  internal enum FieldKeys {
    internal static let todoID: FieldKey = "todoID"
    internal static let tag: FieldKey = "tag"
  }

  internal static let schema = "TodoTags"
  @ID(key: .id)
  internal var id: UUID?

  @Parent(key: FieldKeys.todoID)
  var todo: Todo

  @Parent(key: FieldKeys.tag)
  var tag: Tag

  internal init() {}
}
