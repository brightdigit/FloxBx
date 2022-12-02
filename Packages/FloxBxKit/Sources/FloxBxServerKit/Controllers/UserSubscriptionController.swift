//
//  File.swift
//  
//
//  Created by Leo Dion on 12/2/22.
//

import Foundation
import Vapor
import RouteGroups
import FloxBxDatabase
import FloxBxModels

struct UserSubscriptionController: RouteGroupCollection {
  var routeGroups: [RouteGroupKey : RouteGroups.RouteCollectionBuilder] {
    fatalError()
  }
  
  typealias RouteGroupKeyType = RouteGroupKey
  
  func create(from request: Request) async throws {
    let user : User = try request.auth.require()
    let content : UserSubscriptionRequestContent = try request.content.decode(UserSubscriptionRequestContent.self)
    let tags = try await Tag.findOrCreate(tagValues: content.tags, on: request.db)
    try await user.$tags.attach(tags, on: request.db)
  }
  
  
  func delete(from request: Request) async throws {
    let user : User = try request.auth.require()
    let content : UserSubscriptionRequestContent = try request.content.decode(UserSubscriptionRequestContent.self)
    let tags = try await Tag.find(tagValues: content.tags, on: request.db)
    try await user.$tags.detach(tags, on: request.db)
    
  }
}
