//
//  File.swift
//
//
//  Created by Leo Dion on 12/2/22.
//
import FloxBxNetworking
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct CreateMobileDeviceRequest: ClientBodySuccessRequest {
  public typealias SuccessType = CreateMobileDeviceResponseContent

  public init(body: CreateMobileDeviceRequestContent) {
    self.body = body
  }

  public let body: CreateMobileDeviceRequestContent

  public typealias BodyType = CreateMobileDeviceRequestContent

  public static var requiresCredentials: Bool {
    true
  }

  public var path: String {
    "api/v1/device/mobile"
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    .POST
  }

  public var headers: [String: String] {
    [:]
  }
}