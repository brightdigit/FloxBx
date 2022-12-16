import FluentKit
import Foundation
import FloxBxModels

extension Databases.Middleware {
  public func configure(notify: @escaping (PayloadNotification<TagPayload>) async throws ->  Void){
    use(TagMiddleware())
    use(TodoMiddleware())
    use(TodoTagMiddleware(sendNotification: notify))
  }
}
