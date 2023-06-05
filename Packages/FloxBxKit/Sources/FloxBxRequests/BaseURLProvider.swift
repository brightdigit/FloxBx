import Foundation

public protocol BaseURLProvider {
  var baseURLComponents: URLComponents? { get }
}
