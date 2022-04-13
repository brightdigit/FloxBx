public struct CreateTokenRequestContent: Codable {
  public init(emailAddress: String, password: String) {
    self.emailAddress = emailAddress
    self.password = password
  }

  public let emailAddress: String
  public let password: String
}


public struct SignInRefreshRequest : ClientSuccessRequest {
  
  
  public typealias SuccessType = CreateTokenResponseContent
  
  
  
  
  
  
  public static let requiresCredentials: Bool = true
  
  public let path: String = "api/v1/tokens"
  
  public var parameters: [String : String] {
    [:]
  }
  
  public let method: RequestMethod = .GET
  
  public var headers: [String : String] {
    [:]
  }
}

public struct SignInCreateRequest : ClientBodySuccessRequest {
  public let body: BodyType
  
  public typealias SuccessType = CreateTokenResponseContent
  
  public typealias BodyType = CreateTokenRequestContent
  
  public static let requiresCredentials: Bool = false
  
  public let path: String = "api/v1/tokens"
  
  public var parameters: [String : String] {
    [:]
  }
  
  public let method: RequestMethod = .POST
  
  public var headers: [String : String] {
    [:]
  }
}
  
