public struct SignUpRequest : ClientBodySuccessRequest {
  public let body: CreateUserRequestContent
  
  public var headers: [String : String] {
    return [:]
  }
  
  public static var requiresCredentials: Bool {
    return false
  }
  
  public var path: String {
    "api/v1/users"
  }
  
  public var parameters: [String : String] {
    return [ : ]
  }
  
  public typealias BodyType = CreateUserRequestContent
  
  public typealias SuccessType = CreateUserResponseContent
  
  public var method: RequestMethod { return .POST}
}

public struct CreateUserRequestContent: Codable {
  public init(emailAddress: String, password: String) {
    self.emailAddress = emailAddress
    self.password = password
  }

  public let emailAddress: String
  public let password: String
}
