import Foundation
import Fluent

public final class MobileDevice: Model {
  internal enum FieldKeys {
    internal static let model: FieldKey = "model"
    internal static let operatingSystem: FieldKey = "operatingSystem"
    internal static let deviceToken: FieldKey = "deviceToken"
    internal static let userID: FieldKey = "userID"
  }

  public static let schema = "MobileDevices"
  
  @ID(key: .id)
  public var id: UUID?

  @Field(key: FieldKeys.model)
  public var model: String

  @Field(key: FieldKeys.operatingSystem)
  public var operatingSystem: String

  @Field(key: FieldKeys.deviceToken)
  public var deviceToken: Data?
  
  @Parent(key: FieldKeys.userID)
  public var user: User
  
  public init() {
    
  }
  
  public init(id: UUID? = nil, model: String, operatingSystem: String, deviceToken: Data? = nil) {
    self.id = id
    self.model = model
    self.operatingSystem = operatingSystem
    self.deviceToken = deviceToken
  }
}
