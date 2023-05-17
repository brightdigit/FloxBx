import Foundation

public struct AuthenticationError: LocalizedError {
  public init(innerError: Error) {
    self.innerError = innerError
  }

  public let innerError: Error

  public var errorDescription: String? {
    innerError.localizedDescription
  }
}
