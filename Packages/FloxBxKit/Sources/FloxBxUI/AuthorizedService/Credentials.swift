import FloxBxAuth
import Prch

extension Credentials: URLSessionAuthorization {
  public var httpHeaders: [String: String] {
    guard let token = self.token else {
      return [:]
    }
    return ["Authorization": "Bearer \(token)"]
  }
}
