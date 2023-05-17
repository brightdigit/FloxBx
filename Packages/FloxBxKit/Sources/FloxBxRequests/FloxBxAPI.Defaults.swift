import Foundation
import PrchModel

extension FloxBxAPI {
  enum Defaults {
    public static let encoder: any Encoder<Data> = JSONEncoder()

    public static let decoder: any Decoder<Data> = JSONDecoder()

    public static let headers: [String: String] =
      ["Content-Type": "application/json; charset=utf-8"]
  }
}
