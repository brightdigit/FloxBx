//
import Foundation
//  File.swift
//
//
//  Created by Leo Dion on 12/2/22.
//
import PrchModel
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct DeleteMobileDeviceRequest: ServiceCall {
  public typealias ServiceAPI = FloxBxAPI

  public typealias SuccessType = Empty
  public typealias BodyType = Empty
  public static var requiresCredentials: Bool {
    true
  }

  public var path: String {
    "api/v1/device/mobile/\(id)"
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    .DELETE
  }

  public var headers: [String: String] {
    [:]
  }

  public let id: UUID

  public init(id: UUID) {
    self.id = id
  }
}
