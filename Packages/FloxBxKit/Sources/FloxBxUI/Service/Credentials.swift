import FloxBxAuth
import Prch

extension Credentials: SessionAuthorization {
  public var httpHeaders: [String: String] {
    guard let token = self.token else {
      return [:]
    }
    return ["Authorization": "Bearer \(token)"]
  }
}
