import Fluent
import Vapor

struct CreateTodoRequestContent : Content {
  let title: String
}

struct CreateTodoResponseContent : Content {
  let id: UUID
  let title: String
}

struct TodoController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
      let todos = routes.grouped("todos")
        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
            todo.delete(use: delete)
        }
    }

    func index(from request: Request) throws -> EventLoopFuture<[Todo]> {
      let user = try request.auth.require(User.self)
      return user.$items.get(on: request.db)
    }

    func create(from request: Request) throws -> EventLoopFuture<CreateTodoResponseContent> {
      let user = try request.auth.require(User.self)
      let userID = try user.requireID()
      let content = try request.content.decode(CreateTodoRequestContent.self)
      let todo = Todo(title: content.title, userID: userID)
      return user.$items.create(todo, on: request.db).flatMapThrowing {
        try CreateTodoResponseContent(id: todo.requireID(), title: todo.title)
      }
        
    }

    func delete(from request: Request) throws -> EventLoopFuture<HTTPStatus> {
      let user = try request.auth.require(User.self)
      let todoID : UUID = try request.parameters.require("todoID", as:  UUID.self)
      return user.$items.query(on: request.db).filter(\.$id == todoID).all()
            .flatMap { $0.delete(on: request.db) }
            .transform(to: .noContent)
    }
}
