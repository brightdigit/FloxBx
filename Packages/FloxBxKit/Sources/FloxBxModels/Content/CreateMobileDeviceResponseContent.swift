import Foundation

public struct CreateMobileDeviceResponseContent: Codable {
  public init(id: UUID) {
    self.id = id
  }

  public let id: UUID
}
