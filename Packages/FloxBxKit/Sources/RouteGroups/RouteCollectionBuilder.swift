import Vapor

public struct RouteCollectionBuilder: RouteCollection {
  public init(_ builder: @escaping (RoutesBuilder) throws -> Void) {
    self.builder = builder
  }

  let builder: (RoutesBuilder) throws -> Void

  public func boot(routes: RoutesBuilder) throws {
    try builder(routes)
  }
}
