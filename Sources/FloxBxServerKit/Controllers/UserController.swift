//
//  File.swift
//  
//
//  Created by Leo Dion on 5/12/21.
//

import Fluent
import Vapor

public struct CreateUserRequestContent : Content {
  public init(emailAddress: String, password: String) {
    self.emailAddress = emailAddress
    self.password = password
  }
  
  public let emailAddress : String
  public let password : String
}

public struct CreateUserResponseContent : Content {
  public let token : String
}
struct UserController : RouteCollection {
  func create (from request: Request) -> EventLoopFuture<CreateUserResponseContent> {
    let createUserRequestContent : CreateUserRequestContent
    let user : User
    do {
    createUserRequestContent = try request.content.decode(CreateUserRequestContent.self)
      user = User(email: createUserRequestContent.emailAddress,
                      passwordHash: try Bcrypt.hash(createUserRequestContent.password))
    } catch {
      return request.eventLoop.makeFailedFuture(error)
    }
    

    return user.save(on: request.db).flatMapThrowing {
      let token = try user.generateToken()
      return CreateUserResponseContent(token: token.value)
    }
  }
  
  func boot(routes: RoutesBuilder) throws {
    routes.post("users", use: self.create(from:))
  }
  

}
