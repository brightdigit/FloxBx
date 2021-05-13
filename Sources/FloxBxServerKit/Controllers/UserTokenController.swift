//
//  File.swift
//  
//
//  Created by Leo Dion on 5/12/21.
//

import Fluent
import Vapor

struct CreateTokenRequestContent : Content {
  let emailAddress : String
  let password : String
}

struct CreateTokenResponseContent : Content {
  let token : String
}
struct UserTokenController : RouteCollection {
  func create (from request: Request) -> EventLoopFuture<CreateTokenResponseContent> {
    let createTokenRequestContent : CreateTokenRequestContent
    do {
      createTokenRequestContent = try request.content.decode(CreateTokenRequestContent.self)
    } catch {
      return request.eventLoop.makeFailedFuture(error)
    }

     return User
       .query(on: request.db)
       .filter(\.$email == createTokenRequestContent.emailAddress)
       .first()
       .unwrap(or: Abort(.unauthorized))
       .flatMapThrowing { user -> UserToken in
         guard try user.verify(password: createTokenRequestContent.password) else {
           throw Abort(.unauthorized)
         }

         // create new token for this user
         return try user.generateToken()
       }.flatMap { token in
         // save and return token
         token.save(on: request.db).map {
          CreateTokenResponseContent(token: token.value)
         }
       }

  }
  
  func delete(from request: Request) -> EventLoopFuture<HTTPResponseStatus> {
    let user : User
    do {
      try request.auth.require(UserToken.self)
    } catch {
      return request.eventLoop.makeFailedFuture(error)
    }
  
    return request.eventLoop.future(.noContent)
//    return token.delete(on: request.db).map{
//      request.auth.logout(UserToken.self)
//      return .noContent
//    }
  }
  func boot(routes: RoutesBuilder) throws {
    routes.post("tokens", use: self.create(from:))
    let tokenProtected = routes.grouped(UserToken.authenticator())
    tokenProtected.delete("tokens", use: self.delete(from:))
  }
  

}
