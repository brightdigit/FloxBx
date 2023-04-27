import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

extension URLSession: Session {
  public typealias SessionRequestType = URLRequest

  public typealias SessionResponseType = URLSessionResponse
  public func request(
    _ request: URLRequest,
    _ completed: @escaping (Result<URLSessionResponse, Error>) -> Void
  ) -> SessionTask {
    let task = dataTask(with: request) { data, response, error in
      let result: Result<URLSessionResponse, Error>
      if let error = error {
        result = .failure(error)
      } else if let sessionResponse = URLSessionResponse(
        urlResponse: response, data: data
      ) {
        result = .success(sessionResponse)
      } else {
        result = .failure(RequestError.invalidResponse(response))
      }
      completed(result)
    }
    task.resume()
    return task
  }
  
  
  public func request(_ request: URLRequest) async throws -> URLSessionResponse {
    #if os(iOS) || os(macOS) || os(watchOS) || os(tvOS)
    let tuple = try await self.data(for: request)
    guard let response = URLSessionResponse(tuple) else {
      throw RequestError.invalidResponse(tuple.1)
    }
    return response
    #else
    return try await withCheckedThrowingContinuation { continuation in
      self.dataTask(with: request) { data, response, error in
        let result : Result<URLSessionResponse, Error> = Result<URLSessionResponse?, Error>(catching: {
          try URLSessionResponse(error: error, data: data, urlResponse: response)
        }).flatMap { response in
          guard let response = response else {
            return .failure(RequestError.missingData)
          }
          return .success(response)
        }
        continuation.resume(with: result)
      }
    }
    #endif
  }
}
