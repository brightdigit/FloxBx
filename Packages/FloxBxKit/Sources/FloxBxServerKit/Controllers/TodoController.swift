import FloxBxDatabase
import FloxBxModels
import Fluent
import RouteGroups
import Vapor

internal struct TodoController: RouteGroupCollection {
  var routeGroups: [RouteGroupKey: RouteCollectionBuilder] {
    [
      .bearer: { bearer in
        let todos = bearer.grouped("todos")

        todos.get(use: index)
        todos.post(use: create)
        todos.group(":todoID") { todo in
          todo.delete(use: delete)
          todo.put(use: update)
        }

        let sharedTodos = bearer.grouped("group-sessions", ":sessionID", "todos")
        sharedTodos.get(use: index)
        sharedTodos.post(use: create)
        sharedTodos.group(":todoID") { todo in
          todo.delete(use: delete)
          todo.put(use: update)
        }
      }
    ]
  }

//  internal func boot(routes: RoutesBuilder) throws {
//    let todos = routes.grouped("todos")
//
//    todos.get(use: index)
//    todos.post(use: create)
//    todos.group(":todoID") { todo in
//      todo.delete(use: delete)
//      todo.put(use: update)
//    }
//
//    let sharedTodos = routes.grouped("group-sessions", ":sessionID", "todos")
//    sharedTodos.get(use: index)
//    sharedTodos.post(use: create)
//    sharedTodos.group(":todoID") { todo in
//      todo.delete(use: delete)
//      todo.put(use: update)
//    }
//  }

  internal func index(
    from request: Request
  ) throws -> EventLoopFuture<[CreateTodoResponseContent]> {
    let user = try request.auth.require(User.self)

    let userF = GroupSession.user(fromRequest: request, otherwise: user)
    
    return userF.flatMap { user in
      return user.$items.query(on: request.db).with(\.$tags).all()
    }
    .flatMapEachThrowing(CreateTodoResponseContent.init(todoItem:))
  }

  internal func create(
    from request: Request
  ) async throws -> CreateTodoResponseContent {
    let authUser = try request.auth.require(User.self)
    let content = try request.content.decode(CreateTodoRequestContent.self)
    let todo = Todo(title: content.title)

    async let user = try await GroupSession.user(fromRequest: request, otherwise: authUser)
    async let tags = try await withTaskGroup(of: Tag.self, body: { taskGroup in
      content.tags.map { value in
        taskGroup.addTask {          
          if let tag = try await Tag.find(value, on: request.db) {
            return tag
          } else {
            let newTag = Tag(value)
            try await newTag.create(on: request.db)
            return newTag
          }
          
        }
      }
    })
    
    try await user.$items.create(todo, on: request.db)
    try await todo.$tags.attach(tags, on: request.db)

    return try CreateTodoResponseContent(todoItem: todo)
  }

  internal func update(
    from request: Request
  ) throws -> EventLoopFuture<CreateTodoResponseContent> {
    let user = try request.auth.require(User.self)
    let todoID: UUID = try request.parameters.require("todoID", as: UUID.self)
    let content = try request.content.decode(CreateTodoRequestContent.self)
    let userF = GroupSession.user(fromRequest: request, otherwise: user)

    return userF.flatMap { user in
      user.$items.query(on: request.db)
        .filter(\.$id == todoID)
        .first()
        .unwrap(orError: Abort(.notFound))
        .flatMap { todo -> EventLoopFuture<Void> in
          todo.title = content.title
          return todo.update(on: request.db)
        }
        .transform(to: CreateTodoResponseContent(id: todoID, title: content.title))
    }
  }

  internal func delete(from request: Request) throws -> EventLoopFuture<HTTPStatus> {
    let user = try request.auth.require(User.self)
    let todoID: UUID = try request.parameters.require("todoID", as: UUID.self)
    let userF = GroupSession.user(fromRequest: request, otherwise: user)
    return userF.flatMap { user in
      user.$items.query(on: request.db)
        .filter(\.$id == todoID)
        .all()
        .flatMap { $0.delete(on: request.db) }
        .transform(to: .noContent)
    }
  }
}
