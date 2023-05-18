import Foundation
import PrchModel

public struct UserSubscriptionRequestContent: Codable, ContentEncodable {
  public let tags: [String]
}
