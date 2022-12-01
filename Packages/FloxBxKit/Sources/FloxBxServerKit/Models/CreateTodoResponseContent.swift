import FloxBxDatabase
import FloxBxModels

extension CreateTodoResponseContent {
  internal init(todoItem: Todo) throws {
    todoItem.$tags.
    try self.init(id: todoItem.requireID(), title: todoItem.title, tags: todoItem.tags.compactMap{$0.id})
  }
}
