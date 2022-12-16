import FloxBxModels
import FluentKit
import Foundation

extension Databases.Middleware {
  public func configure(notify: @escaping (PayloadNotification<TagPayload>) async throws -> Void) {
    use(TagMiddleware())
    use(TodoMiddleware())
    use(TodoTagMiddleware(sendNotification: notify))
  }
}
