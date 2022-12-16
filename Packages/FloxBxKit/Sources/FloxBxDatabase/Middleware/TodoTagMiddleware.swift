import FluentKit
import FloxBxModels

struct TodoTagMiddleware: AsyncModelMiddleware {
  typealias Model = TodoTag
  
  let sendNotification : (PayloadNotification<TagPayload>) async throws ->  Void

  func create(model: TodoTag, on db: Database, next: AnyAsyncModelResponder) async throws {
    let devices = try await model.$tag.query(on: db).with(\.$subscribers).with(\.$subscribers, { subscriber in
      subscriber.with(\.$mobileDevices)
    }).all().flatMap(\.subscribers).flatMap(\.mobileDevices)
    let notifications = devices.compactMap { device in
      device.deviceToken.map{ deviceToken in
        PayloadNotification(topic: device.topic, deviceToken: deviceToken, payload: TagPayload(action: .added, name: model.$tag.id))
      }
    }
    
    
    for notification in notifications {
      try await self.sendNotification(notification)
    }
    try await next.create(model, on: db)
  }

  func delete(model: TodoTag, force: Bool, on db: Database, next: AnyAsyncModelResponder) async throws {
    let subscribers = try await model.$tag.query(on: db).with(\.$subscribers).all().flatMap(\.subscribers)
    return try await next.delete(model, force: force, on: db)
  }
}
