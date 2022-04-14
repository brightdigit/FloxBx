public struct GetTodoListRequest: ClientSuccessRequest {
  public typealias SuccessType = [CreateTodoResponseContent]

  public typealias BodyType = Void

  public static var requiresCredentials: Bool {
    true
  }

  public var path: String {
    "api/v1/todos"
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    .GET
  }

  public var headers: [String: String] {
    [:]
  }
}
