import FloxBxDatabase
import FloxBxModels
import RouteGroups
import Fluent
import Vapor

internal struct UserController: RouteGroupCollection {
  typealias RouteGroupKeyType = RouteGroupKey
  internal func create(
    from request: Request
  ) -> EventLoopFuture<CreateUserResponseContent> {
    let createUserRequestContent: CreateUserRequestContent
    let user: User
    do {
      createUserRequestContent = try request.content.decode(CreateUserRequestContent.self)
      user = User(
        email: createUserRequestContent.emailAddress,
        passwordHash: try Bcrypt.hash(createUserRequestContent.password)
      )
    } catch {
      return request.eventLoop.makeFailedFuture(error)
    }

    return user.save(on: request.db).flatMapThrowing {
      let token = try user.generateToken()
      return CreateUserResponseContent(token: token.value)
    }
  }

  internal func get(from request: Request) throws -> GetUserResponseContent {
    let user = try request.auth.require(User.self)
    let username = user.email
    let id = try user.requireID()
    return GetUserResponseContent(id: id, username: username)
  }
  
  var routeGroups: [RouteGroupKey : RouteCollectionBuilder] {
    [
      .publicAPI : { routes in
        
            routes.post("users", use: create(from:))
        
      }
    ]
  }

//  internal func boot(routes: RoutesBuilder) throws {
//    routes.post("users", use: create(from:))
//  }
}
