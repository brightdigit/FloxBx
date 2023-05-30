//
import FloxBxModels
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

public struct UserSubscriptionRequest: ServiceCall {
  public typealias BodyType = UserSubscriptionRequestContent
  public typealias ServiceAPI = FloxBxAPI

  public typealias SuccessType = Empty
  public static var requiresCredentials: Bool {
    true
  }

  public let body: UserSubscriptionRequestContent

  public var path: String

  public var parameters: [String: String]

  public var method: RequestMethod

  public var headers: [String: String]
}
