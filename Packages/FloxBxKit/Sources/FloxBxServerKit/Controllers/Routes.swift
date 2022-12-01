//
// Routes.swift
// Copyright © 2022 Bright Digit, LLC.
// All Rights Reserved.
// Created by Leo G Dion.
//

import Vapor
import RouteGroups
import FloxBxDatabase

struct Routes: GroupCollection {
  
  typealias RouteGroupKeyType = RouteGroupKey
  
  func groupBuilder(routes: RoutesBuilder) -> GroupBuilder<RouteGroupKey> {
                let api = routes.grouped("api", "v1")
                let bearer = api.grouped(UserToken.authenticator())
    
        return GroupBuilder<RouteGroupKey>(groups: [
    
                  .bearer: bearer,
                  .publicAPI: api
                ])
  }
  
  func boot(groups: GroupBuilder<RouteGroupKey>) throws {
        try groups.register(collection: UserTokenController())
        try groups.register(collection: UserTokenController())
        try groups.register(collection: TodoController())
        try groups.register(collection: GroupSessionController())
  }
}
