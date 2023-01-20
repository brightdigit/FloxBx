import FloxBxAuth

internal protocol HeaderProvider {
  associatedtype RequestBuilderType: RequestBuilder
  var credentialsContainer: CredentialsContainer { get }
  var builder: RequestBuilderType { get }
  var headers: [String: String] { get }
}

extension HeaderProvider {
  public func headers(
    withCredentials requiresCredentials: Bool
  ) throws -> [String: String] {
    try Self.headers(
      withCredentials: requiresCredentials ? credentialsContainer : nil,
      from: builder,
      mergedWith: headers
    )
  }

  public static func headers(
    withCredentials credentialsContainer: CredentialsContainer?,
    from builder: RequestBuilderType,
    mergedWith headers: [String: String]
  ) throws -> [String: String] {
    let creds = try credentialsContainer?.fetch()

    let authorizationHeaders: [String: String]
    if let creds = creds {
      authorizationHeaders = builder.headers(basedOnCredentials: creds)
    } else {
      authorizationHeaders = [:]
    }

    return headers.merging(authorizationHeaders) { _, rhs in
      rhs
    }
  }
}
