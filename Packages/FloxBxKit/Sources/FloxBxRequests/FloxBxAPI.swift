import Foundation
import PrchModel

public class FloxBxAPI: API {
  public typealias RequestDataType = Data

  public typealias ResponseDataType = Data

  public var isReady: Bool {
    baseURLProvider.baseURLComponents != nil
  }

  public let baseURLProvider: BaseURLProvider

  public var baseURLComponents: URLComponents {
    guard let baseURLComponents = baseURLProvider.baseURLComponents else {
      assertionFailure("BaseURLProvider is not ready")
      return URLComponents()
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

  public init(baseURLProvider: BaseURLProvider) {
    self.baseURLProvider = baseURLProvider
  }
}
