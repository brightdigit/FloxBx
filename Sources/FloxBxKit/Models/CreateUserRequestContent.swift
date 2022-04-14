public struct SignUpRequest: ClientBodySuccessRequest {
  public let body: CreateUserRequestContent

  public var headers: [String: String] {
    [:]
  }

  public static var requiresCredentials: Bool {
    false
  }

  public var path: String {
    "api/v1/users"
  }

  public var parameters: [String: String] {
    [:]
  }

  public typealias BodyType = CreateUserRequestContent

  public typealias SuccessType = CreateUserResponseContent

  public var method: RequestMethod { .POST }
}

public struct CreateUserRequestContent: Codable {
  public init(emailAddress: String, password: String) {
    self.emailAddress = emailAddress
    self.password = password
  }

  public let emailAddress: String
  public let password: String
}
