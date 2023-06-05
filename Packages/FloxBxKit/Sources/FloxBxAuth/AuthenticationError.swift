import Foundation

public struct AuthenticationError: LocalizedError {
  public let innerError: Error

  public var errorDescription: String? {
    innerError.localizedDescription
  }

  public init(innerError: Error) {
    self.innerError = innerError
  }
}
