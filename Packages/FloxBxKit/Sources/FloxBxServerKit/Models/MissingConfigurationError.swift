import Foundation

internal struct MissingConfigurationError: Error {
  internal let key: String
}
