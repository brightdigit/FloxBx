import FloxBxModels
import Foundation
import PrchModel
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct PatchMobileDeviceRequest: ServiceCall {
  public typealias SuccessType = Empty
  public typealias BodyType = PatchMobileDeviceRequestContent
  public typealias ServiceAPI = FloxBxAPI

  public static var requiresCredentials: Bool {
    true
  }

  public let id: UUID
  public let body: PatchMobileDeviceRequestContent

  public var path: String {
    "api/v1/device/mobile/\(id)"
  }

  public var parameters: [String: String] {
    [:]
  }

  public var method: RequestMethod {
    .PATCH
  }

  public var headers: [String: String] {
    [:]
  }

  public init(id: UUID, body: PatchMobileDeviceRequestContent) {
    self.id = id
    self.body = body
  }
}
