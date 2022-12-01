//
// Routes.swift
// Copyright © 2022 Bright Digit, LLC.
// All Rights Reserved.
// Created by Leo G Dion.
//

import Vapor

public protocol GroupCollection : RouteCollection {
  associatedtype RouteGroupKeyType : Hashable
  func groupBuilder(routes: RoutesBuilder) -> GroupBuilder<RouteGroupKeyType>
  func boot(groups: GroupBuilder<RouteGroupKeyType>) throws
}

public extension GroupCollection {
  func boot(routes: RoutesBuilder) throws {
    let groupBuilder = self.groupBuilder(routes: routes)
    try self.boot(groups: groupBuilder)    
  }
}
