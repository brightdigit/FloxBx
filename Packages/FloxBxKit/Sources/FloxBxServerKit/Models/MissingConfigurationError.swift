import Foundation

struct MissingConfigurationError: Error {
  public let key: String
}
