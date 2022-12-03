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

public struct CreateMobileDeviceRequest: ClientBodyRequest {
  public let body: CreateMobileDeviceRequestContent

  public typealias BodyType = CreateMobileDeviceRequestContent

  public static var requiresCredentials: Bool {
    true
  }

  public var path: String

  public var parameters: [String: String]

  public var method: FloxBxNetworking.RequestMethod

  public var headers: [String: String]
}

public struct PatchMobileDeviceRequest: ClientBodyRequest {
  public let body: PatchMobileDeviceRequestContent

  public typealias BodyType = PatchMobileDeviceRequestContent

  public static var requiresCredentials: Bool {
    true
  }

  public var path: String

  public var parameters: [String: String]

  public var method: FloxBxNetworking.RequestMethod

  public var headers: [String: String]
}

public struct UserSubscriptionRequest: ClientBodyRequest {
  public let body: UserSubscriptionRequestContent

  public typealias BodyType = UserSubscriptionRequestContent

  public static var requiresCredentials: Bool {
    true
  }

  public var path: String

  public var parameters: [String: String]

  public var method: FloxBxNetworking.RequestMethod

  public var headers: [String: String]
}

// public struct CreateMobileDeviceRequestContent : Codable {
//  public let model : String
//  public let operatingSystem : String
//  public let deviceToken : Data?
// }
//
// public struct PatchMobileDeviceRequestContent : Codable {
//  public let model : String?
//  public let operatingSystem : String?
//  public let deviceToken : Data?
// }
//
// public struct UserSubscriptionRequestContent : Codable {
//  public let tags : [String]
// }
