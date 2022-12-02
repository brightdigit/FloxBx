//
//  File.swift
//  
//
//  Created by Leo Dion on 12/2/22.
//

import Foundation
import Vapor
import FloxBxDatabase
import RouteGroups
import FloxBxModels

extension MobileDevice {
  convenience init(content: CreateMobileDeviceRequestContent) {
    self.init(
      model: content.model,
      operatingSystem: content.operatingSystem,
      deviceToken: content.deviceToken
    )
  }
  
  func patch(content: PatchMobileDeviceRequestContent) {
    self.deviceToken = content.deviceToken ?? self.deviceToken
    self.operatingSystem = content.operatingSystem ?? self.operatingSystem
    self.model = content.model ?? self.model
  }
}

struct MobileDeviceController: RouteGroupCollection {
  var routeGroups: [RouteGroupKey : RouteGroups.RouteCollectionBuilder] {
    fatalError()
  }
  
  typealias RouteGroupKeyType = RouteGroupKey
  
  func create(from request: Request) async throws {
    let user = try request.auth.require(User.self)
    let content = try request.content.decode(CreateMobileDeviceRequestContent.self)
    let device = MobileDevice(content: content)
    try await user.$mobileDevices.create(device, on: request.db)
  }
  
  func patch(from request: Request) async throws {
    let user = try request.auth.require(User.self)
    let deviceID = try request.parameters.require("deviceID", as: UUID.self)
    let content : PatchMobileDeviceRequestContent = try request.content.decode(PatchMobileDeviceRequestContent.self)
    let device = try await user.$mobileDevices.query(on: request.db).filter(.id, .equality(inverse: false), deviceID).first()
    
    guard let device else {
      throw Abort(.notFound)
    }
    
    device.patch(content: content)
    
    try await device.update(on: request.db)
  }
  
  func delete(from request: Request) async throws {
    let user = try request.auth.require(User.self)
    let deviceID : UUID = try request.parameters.require("deviceID")
    let device = try await user.$mobileDevices.query(on: request.db).filter(.id, .equality(inverse: false), deviceID).first()
    
    guard let device else {
      throw Abort(.notFound)
    }
    try await device.delete(on: request.db)
  }
  
}
