import FluentKit

struct TodoMiddleware: AsyncModelMiddleware {
  // let apns : Application.APNS
  typealias Model = Todo

  func update(model: Todo, on db: Database, next: AnyAsyncModelResponder) async throws {
    let subscribers = try await model.$tags.query(on: db).with(\.$subscribers).all().flatMap { $0.subscribers }.uniqued(on: { $0.id })
    try await next.update(model, on: db)
  }

  func delete(model: Todo, force: Bool, on db: Database, next: AnyAsyncModelResponder) async throws {
    let subscribers = try await model.$tags.query(on: db).with(\.$subscribers).all().flatMap { $0.subscribers }.uniqued(on: { $0.id })
    try await next.delete(model, force: force, on: db)
  }
}
