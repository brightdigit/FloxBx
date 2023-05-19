import Foundation

public struct StaticBaseURLProvider: BaseURLProvider {
  public init(baseURLComponents: URLComponents) {
    staticBaseURLComponents = baseURLComponents
  }

  public let staticBaseURLComponents: URLComponents

  public var baseURLComponents: URLComponents? {
    staticBaseURLComponents
  }
}
