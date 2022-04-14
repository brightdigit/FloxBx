import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct DeleteTodoItemRequest: ClientVoidRequest {
  let itemID: UUID
  static var requiresCredentials: Bool {
    true
  }

  var path: String {
    "api/v1/todos/\(itemID)"
  }

  var parameters: [String: String] {
    [:]
  }

  var method: RequestMethod {
    .DELETE
  }

  var headers: [String: String] {
    [:]
  }
}
