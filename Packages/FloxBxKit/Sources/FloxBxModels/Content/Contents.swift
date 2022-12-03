import Foundation
public struct CreateMobileDeviceRequestContent: Codable {
  public let model: String
  public let operatingSystem: String
  public let deviceToken: Data?
}

public struct PatchMobileDeviceRequestContent: Codable {
  public let model: String?
  public let operatingSystem: String?
  public let deviceToken: Data?
}

public struct UserSubscriptionRequestContent: Codable {
  public let tags: [String]
}

public struct CreateGroupSessionResponseContent: Codable {
  public let id: UUID

  public init(id: UUID) {
    self.id = id
  }
}
