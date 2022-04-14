import Foundation
public struct GetTodoListRequest: ClientSuccessRequest {
  public typealias SuccessType = [CreateTodoResponseContent]

  public typealias BodyType = Void
  
  let userID : UUID?

  public static var requiresCredentials: Bool {
    true
  }

  public var path: String {
    if let userID = userID {
      return "api/v1/users/\(userID)/todos"
    } else {
      return "api/v1/todos"
    }
    
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
