import FloxBxRequests
import Foundation
import PrchModel

struct PreviewService: FloxBxServiceProtocol {
  func request<RequestType>(_: RequestType) async throws -> RequestType.SuccessType.DecodableType where RequestType: PrchModel.ServiceCall, FloxBxRequests.FloxBxAPI == RequestType.ServiceAPI {
    fatalError()
  }
}
