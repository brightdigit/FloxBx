import Vapor

public protocol GroupCollection: RouteCollection {
  associatedtype RouteGroupKeyType: Hashable
  func groupBuilder(routes: any RoutesBuilder) -> GroupBuilder<RouteGroupKeyType>
  func boot(groups: GroupBuilder<RouteGroupKeyType>) throws
}

extension GroupCollection {
  public func boot(routes: any RoutesBuilder) throws {
    let groupBuilder = self.groupBuilder(routes: routes)
    try boot(groups: groupBuilder)
  }
}
