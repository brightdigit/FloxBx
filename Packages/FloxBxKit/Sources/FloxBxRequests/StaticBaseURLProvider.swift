import Foundation

public struct StaticBaseURLProvider: BaseURLProvider {
  public let staticBaseURLComponents: URLComponents

  public var baseURLComponents: URLComponents? {
    staticBaseURLComponents
  }

  public init(baseURLComponents: URLComponents) {
    staticBaseURLComponents = baseURLComponents
  }
}
