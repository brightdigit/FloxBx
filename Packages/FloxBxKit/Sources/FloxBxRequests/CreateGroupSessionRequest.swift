import FloxBxModels
import Foundation
import PrchModel

public struct CreateGroupSessionRequest: ServiceCall {
  public static var requiresCredentials: Bool {
    true
  }

  public typealias BodyType = Empty

  public typealias SuccessType = CreateGroupSessionResponseContent

  public var path: String {
    "api/v1/group-sessions"
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    .POST
  }

  public var headers: [String: String] {
    [:]
  }

  public init() {}
}
