import Foundation
import PrchModel

extension FloxBxAPI {
  internal enum Defaults {
    internal static let encoder: any Encoder<Data> = JSONEncoder()

    internal static let decoder: any Decoder<Data> = JSONDecoder()

    internal static let headers: [String: String] =
      ["Content-Type": "application/json; charset=utf-8"]
  }
}
