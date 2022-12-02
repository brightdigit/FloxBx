import FluentKit

struct TodoTagMiddleware: AsyncModelMiddleware {
  typealias Model = TodoTag

  func create(model: TodoTag, on db: Database, next _: AnyAsyncModelResponder) async throws {
    let subscribers = try await model.$tag.query(on: db).with(\.$subscribers).all().flatMap(\.subscribers)
    return try await model.create(on: db)
  }

  func delete(model: TodoTag, force: Bool, on db: Database, next _: AnyAsyncModelResponder) async throws {
    let subscribers = try await model.$tag.query(on: db).with(\.$subscribers).all().flatMap(\.subscribers)
    return try await model.delete(force: force, on: db)
  }
}
