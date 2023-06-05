import Foundation
import StealthyStash

extension Data {
  internal func string(encoding: String.Encoding = .utf8) -> String? {
    String(data: self, encoding: encoding)
  }
}

extension AnyStealthyProperty {
  public var dataString: String {
    property.dataString
  }
}

extension StealthyProperty {
  public var dataString: String {
    data.string() ?? ""
  }
}
