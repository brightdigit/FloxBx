import FluentKit

struct TodoTagMiddleware: AsyncModelMiddleware {
  typealias Model = TodoTag

  func create(model: TodoTag, on db: Database, next: AnyAsyncModelResponder) async throws {
    let subscribers = try await model.$tag.query(on: db).with(\.$subscribers).all().flatMap(\.subscribers)
    try await next.create(model, on: db)
  }

  func delete(model: TodoTag, force: Bool, on db: Database, next: AnyAsyncModelResponder) async throws {
    let subscribers = try await model.$tag.query(on: db).with(\.$subscribers).all().flatMap(\.subscribers)
    return try await next.delete(model, force: force, on: db)
  }
}
