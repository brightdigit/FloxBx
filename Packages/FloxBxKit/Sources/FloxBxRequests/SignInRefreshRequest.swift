import FloxBxModels
import PrchModel

public struct SignInRefreshRequest: ServiceCall {
  public typealias SuccessType = CreateTokenResponseContent

  public static let requiresCredentials = true

  public let path: String = "api/v1/tokens"

  public var parameters: [String: String] {
    [:]
  }

  public let method: RequestMethod = .GET

  public var headers: [String: String] {
    [:]
  }

  public init() {}
}
