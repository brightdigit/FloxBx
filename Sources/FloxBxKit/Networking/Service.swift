import Foundation

public protocol Service {
  func save(credentials: Credentials) throws

  func fetchCredentials() throws -> Credentials?

  func beginRequest<RequestType: ClientRequest>(_ request: RequestType, _ completed: @escaping (Result<RequestType.SuccessType, Error>) -> Void) where
    RequestType.SuccessType: Decodable,
    RequestType.BodyType == Void

  func beginRequest<RequestType: ClientRequest>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where
    RequestType.SuccessType == Void,
    RequestType.BodyType == Void

  func beginRequest<RequestType: ClientRequest>(_ request: RequestType, _ completed: @escaping (Result<RequestType.SuccessType, Error>) -> Void) where
    RequestType.SuccessType: Decodable,
    RequestType.BodyType: Encodable

  func beginRequest<RequestType: ClientRequest>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where
    RequestType.SuccessType == Void,
    RequestType.BodyType: Encodable
}
