//
//  File.swift
//  
//
//  Created by Leo Dion on 5/12/21.
//

import Fluent
import Vapor

struct CreateUserRequestContent : Content {
  let emailAddress : String
  let password : String
}

struct CreateUserResponseContent : Content {
  let token : String
}
struct UserController : RouteCollection {
  func create (from request: Request) -> EventLoopFuture<CreateUserResponseContent> {
    let createUserRequestContent : CreateUserRequestContent
    do {
    createUserRequestContent = try request.content.decode(CreateUserRequestContent.self)
    } catch {
      return request.eventLoop.makeFailedFuture(error)
    }
    let user = User(email: createUserRequestContent.emailAddress, password: createUserRequestContent.password)
    return user.save(on: request.db).flatMapThrowing {
      let token = try user.generateToken()
      return CreateUserResponseContent(token: token.value)
    }
  }
  func boot(routes: RoutesBuilder) throws {
    routes.post("users", use: self.create(from:))
  }
  

}
