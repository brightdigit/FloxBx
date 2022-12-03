import FluentKit
import Foundation

extension Databases.Middleware {
  public func configure() {
    use(TagMiddleware())
    use(TodoMiddleware())
    use(TodoTagMiddleware())
  }
}
