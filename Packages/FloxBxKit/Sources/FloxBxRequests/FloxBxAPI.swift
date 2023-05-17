import Foundation
import PrchModel

public protocol BaseURLProvider {
  var baseURLComponents: URLComponents? { get }
}

public class FloxBxAPI: API {
  public init(baseURLProvider: BaseURLProvider) {
    self.baseURLProvider = baseURLProvider
  }

  public var isReady: Bool {
    baseURLProvider.baseURLComponents != nil
  }

  enum Defaults {
    public static let encoder: any Encoder<Data> = JSONEncoder()

    public static let decoder: any Decoder<Data> = JSONDecoder()

    public static let headers: [String: String] = ["Content-Type": "application/json; charset=utf-8"]
  }

  public let baseURLProvider: BaseURLProvider
  public var baseURLComponents: URLComponents {
    guard let baseURLComponents = baseURLProvider.baseURLComponents else {
      fatalError()
    }

    return baseURLComponents
  }

  public var headers: [String: String] {
    Defaults.headers
  }

  public var encoder: any Encoder<Data> {
    Defaults.encoder
  }

  public var decoder: any Decoder<Data> {
    Defaults.decoder
  }

  public typealias RequestDataType = Data

  public typealias ResponseDataType = Data
}
