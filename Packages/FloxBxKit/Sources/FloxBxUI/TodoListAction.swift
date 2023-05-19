import FloxBxModels

enum TodoListAction: CustomStringConvertible {
  case update(CreateTodoResponseContent, at: Int)
  case append(TodoContentItem)

  var description: String {
    switch self {
    case let .update(content, at: index):
      return "update \(content) at \(index)"
    case let .append(item):
      return "append \(item)"
    }
  }
}
