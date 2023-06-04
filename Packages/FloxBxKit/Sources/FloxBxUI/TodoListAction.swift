import FloxBxModels

internal enum TodoListAction: CustomStringConvertible {
  // swiftlint:disable:next identifier_name
  case update(CreateTodoResponseContent, at: Int)
  case append(TodoContentItem)

  internal var description: String {
    switch self {
    case let .update(content, at: index):
      return "update \(content) at \(index)"
    case let .append(item):
      return "append \(item)"
    }
  }
}
