//
//  File.swift
//  
//
//  Created by Leo Dion on 4/11/22.
//

import Foundation
import Prch

public enum RequestError : Error {
  case missingData
  case statusCode(Int)
  case invalidResponse(URLResponse?)
}

public protocol SessionResponse {
  associatedtype DataType
  var statusCode : Int { get }
  var data : DataType?  { get }
  
}
public protocol SessionRequest {
  associatedtype DataType
}

extension URLRequest : SessionRequest {
  public typealias DataType = Data
}
public struct URLRequestBuilder : RequestBuilder {
  public func build<BodyRequestType, CoderType>(request: BodyRequestType, withBaseURL baseURLComponents: URLComponents, withHeaders headers: [String : String], withEncoder encoder: CoderType) throws -> URLRequest where BodyRequestType : ClientRequest, CoderType : Coder, BodyRequestType.BodyType == Void, CoderType.DataType == Data {
        var componenents = baseURLComponents
        componenents.path = request.path
        componenents.queryItems = request.parameters.map(URLQueryItem.init)
    
        let url = componenents.url!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
    
        let allHeaders = headers.merging(request.headers, uniquingKeysWith: {(lhs, _) in lhs})
        for (field, value) in allHeaders {
          urlRequest.addValue(value, forHTTPHeaderField: field)
        }
    
    
        
    
        return urlRequest
  }
  
  public func build<BodyRequestType, CoderType>(request: BodyRequestType, withBaseURL baseURLComponents: URLComponents, withHeaders headers: [String : String], withEncoder encoder: CoderType) throws -> URLRequest where BodyRequestType : ClientRequest, CoderType : Coder, BodyRequestType.BodyType : Encodable, CoderType.DataType == Data {
    var componenents = baseURLComponents
    componenents.path = "/\(request.path)"
    componenents.queryItems = request.parameters.map(URLQueryItem.init)

    let url = componenents.url!
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = request.method.rawValue

    let allHeaders = headers.merging(request.headers, uniquingKeysWith: {(lhs, _) in lhs})
    for (field, value) in allHeaders {
      urlRequest.addValue(value, forHTTPHeaderField: field)
    }


    urlRequest.httpBody = try encoder.encode(request.body)

    return urlRequest
  }
  
//  public func build<BodyRequestType, CoderType>(request: BodyRequestType, withBaseURL baseURLComponents: URLComponents, withHeaders headers: [String : String], withEncoder encoder: CoderType) throws -> URLRequest where BodyRequestType : ClientRequest, CoderType : Coder, CoderType.DataType == Data {
//    var componenents = baseURLComponents
//    componenents.path = request.path
//    componenents.queryItems = request.parameters.map(URLQueryItem.init)
//
//    let url = componenents.url!
//    var urlRequest = URLRequest(url: url)
//    urlRequest.httpMethod = request.method.rawValue
//
//    let allHeaders = headers.merging(request.headers, uniquingKeysWith: {(lhs, _) in lhs})
//    for (field, value) in allHeaders {
//      urlRequest.addValue(value, forHTTPHeaderField: field)
//    }
//
//
//    urlRequest.httpBody = try encoder.encode(request.body)
//
//    return urlRequest
//  }
  
  
  public func headers(basedOnCredentials credentials: Credentials) -> [String : String] {
    guard let token = credentials.token else {
      return [:]
    }
    return ["Authorization": "Bearer \(token)"]
    
  }
  
//  public func build<BodyRequestType, CoderType>(request: BodyRequestType, withHeaders headers: [String : String], withEncoder encoder: CoderType) throws -> URLRequest where BodyRequestType : ClientBaseRequest, CoderType : Coder, CoderType.DataType == Data {
//    var componenents = URLComponents()
//    componenents.path = request.path
//    componenents.queryItems = request.parameters.map(URLQueryItem.init)
//
//    let url = componenents.url!
//    var urlRequest = URLRequest(url: url)
//    urlRequest.httpMethod = request.method.rawValue
//
//    let allHeaders = headers.merging(request.headers, uniquingKeysWith: {(lhs, _) in lhs})
//    for (field, value) in allHeaders {
//      urlRequest.addValue(value, forHTTPHeaderField: field)
//    }
//
//    return urlRequest
//  }
  
  public typealias SessionRequestType = URLRequest
  
}

public protocol RequestBuilder {
  associatedtype SessionRequestType : SessionRequest
  func build<BodyRequestType : ClientRequest, CoderType : Coder>(request: BodyRequestType, withBaseURL baseURLComponents: URLComponents, withHeaders headers: [String: String], withEncoder encoder: CoderType) throws -> SessionRequestType where CoderType.DataType == SessionRequestType.DataType, BodyRequestType.BodyType : Encodable
  
  func build<BodyRequestType : ClientRequest, CoderType : Coder>(request: BodyRequestType, withBaseURL baseURLComponents: URLComponents, withHeaders headers: [String: String], withEncoder encoder: CoderType) throws -> SessionRequestType where CoderType.DataType == SessionRequestType.DataType, BodyRequestType.BodyType == Void
  func headers(basedOnCredentials credentials: Credentials) -> [String: String]
}

public enum RequestMethod : String {
  case POST
  case GET
}

public protocol ClientRequest : ClientBaseRequest {
  associatedtype SuccessType
  associatedtype BodyType
  
  var body : BodyType { get }
}


public protocol ClientBodySuccessRequest : ClientRequest where SuccessType: Codable, BodyType: Codable {
  
  
  var body : BodyType { get }
  
}
public protocol ClientBodyRequest : ClientBaseRequest {
  associatedtype BodyType : Codable
  
  var body : BodyType { get }
}

public protocol ClientSuccessRequest : ClientBaseRequest {
  
  associatedtype SuccessType : Codable
}
public protocol ClientBaseRequest {
  
  static var requiresCredentials : Bool { get }
  var path : String { get }
  var parameters : [ String : String ] { get }
  var method : RequestMethod { get }
  var headers : [ String : String ] { get }
  
}

public protocol Coder {
  associatedtype DataType
  
  func encode<CodableType : Encodable>(_ value: CodableType) throws  -> DataType
  
  func decode<CodableType : Decodable>(_ : CodableType.Type, from data: DataType) throws  -> CodableType
}

public protocol Session {
  associatedtype SessionRequestType : SessionRequest
  associatedtype SessionResponseType : SessionResponse
  @discardableResult
  func request(_ request: SessionRequestType, _ completed: @escaping(Result<SessionResponseType, Error>) -> Void) -> SessionTask
}



public protocol Service {
  //  func beginRequest<RequestType : ClientSuccessRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void)
  //
  //  func beginRequest<RequestType : ClientBodySuccessRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void)
  //
  //
  //  func beginRequest<RequestType : ClientBodyRequest>(_ request: RequestType, _ completed: @escaping(Error?) -> Void)
  
  
  func beginRequest<RequestType : ClientRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void) where
  RequestType.SuccessType : Decodable,
  RequestType.BodyType == Void
  
  func beginRequest<RequestType : ClientRequest>(_ request: RequestType, _ completed: @escaping(Error?) -> Void) where
  RequestType.SuccessType == Void,
  RequestType.BodyType == Void
  
  
  
  func beginRequest<RequestType : ClientRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void) where
  RequestType.SuccessType : Decodable,
  RequestType.BodyType : Encodable
  
  func beginRequest<RequestType : ClientRequest>(_ request: RequestType, _ completed: @escaping(Error?) -> Void) where
  RequestType.SuccessType == Void,
  RequestType.BodyType : Encodable
  //  func signUp(withCredentials credentials: Credentials, _ completed: @escaping (Result<Credentials, Error>) -> Void )
  //  func signIn(withCredentials credentials: Credentials, _ completed: @escaping (Result<Credentials, Error>) -> Void )
  //  func deleteTodoItem(withID id: UUID, _ completed: @escaping (Error?) -> Void)
  //  func saveTodoItem(_ item: TodoContentItem, forUserID userID: UUID?, _ completed: @escaping (Result<CreateTodoResponseContent, Error>) -> Void)
}

public class ServiceImpl<CoderType : Coder, SessionType : Session, RequestBuilderType : RequestBuilder> : Service where SessionType.SessionRequestType == RequestBuilderType.SessionRequestType, RequestBuilderType.SessionRequestType.DataType == CoderType.DataType, SessionType.SessionResponseType.DataType == CoderType.DataType {
  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Result<RequestType.SuccessType, Error>) -> Void) where RequestType : ClientRequest, RequestType.BodyType : Encodable, RequestType.SuccessType : Decodable {
    let sessionRequest : SessionType.SessionRequestType
    let creds : Credentials?
    do {
      creds = try self.credentialsContainer.fetch()
    } catch {
      completed(.failure(error))
      return
    }
    let authorizationHeaders : [String:String]
    if let creds = creds, RequestType.requiresCredentials {
      authorizationHeaders = self.builder.headers(basedOnCredentials: creds)
    } else {
      authorizationHeaders = [:]
    }

    let headers = self.headers.merging(authorizationHeaders) { _, rhs in
      return rhs
    }
    do {
      sessionRequest = try builder.build(request: request, withBaseURL: self.baseURLComponents, withHeaders: headers, withEncoder: self.coder)
    } catch {
      return
    }
    self.session.request(sessionRequest) { result in

      let decodedResult :  Result<RequestType.SuccessType, Error> = result.flatMap { data in
        guard let bodyData = data.data else {
          return Result<RequestType.SuccessType, Error>.failure(RequestError.missingData)
        }

        return Result {
          try self.coder.decode(RequestType.SuccessType.self, from: bodyData)
        }
      }
      completed(decodedResult)
    }
  }
  
  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where RequestType : ClientRequest, RequestType.BodyType : Encodable, RequestType.SuccessType == Void {
    let sessionRequest : SessionType.SessionRequestType
    let creds : Credentials?
    do {
      creds = try self.credentialsContainer.fetch()
    } catch {
      completed(error)
      return
    }
    let authorizationHeaders : [String:String]
    if let creds = creds, RequestType.requiresCredentials {
      authorizationHeaders = self.builder.headers(basedOnCredentials: creds)
    } else {
      authorizationHeaders = [:]
    }

    let headers = self.headers.merging(authorizationHeaders) { _, rhs in
      return rhs
    }
    do {
      sessionRequest = try builder.build(request: request, withBaseURL: self.baseURLComponents, withHeaders: headers, withEncoder: self.coder)
    } catch {
      return
    }
    self.session.request(sessionRequest) { result in

      completed(result.asVoid().asError())
    }
  }
  
  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Result<RequestType.SuccessType, Error>) -> Void) where RequestType : ClientRequest, RequestType.BodyType == Void, RequestType.SuccessType : Decodable {
        let sessionRequest : SessionType.SessionRequestType
        let creds : Credentials?
        do {
          creds = try self.credentialsContainer.fetch()
        } catch {
          completed(.failure(error))
          return
        }
        let authorizationHeaders : [String:String]
        if let creds = creds, RequestType.requiresCredentials {
          authorizationHeaders = self.builder.headers(basedOnCredentials: creds)
        } else {
          authorizationHeaders = [:]
        }
    
        let headers = self.headers.merging(authorizationHeaders) { _, rhs in
          return rhs
        }
        do {
          sessionRequest = try builder.build(request: request, withBaseURL: self.baseURLComponents, withHeaders: headers, withEncoder: self.coder)
        } catch {
          return
        }
        self.session.request(sessionRequest) { result in
    
          let decodedResult :  Result<RequestType.SuccessType, Error> = result.flatMap { data in
            guard let bodyData = data.data else {
              return Result<RequestType.SuccessType, Error>.failure(RequestError.missingData)
            }
    
            return Result {
              try self.coder.decode(RequestType.SuccessType.self, from: bodyData)
            }
          }
          completed(decodedResult)
        }
  }
  
  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where RequestType : ClientRequest, RequestType.BodyType == Void, RequestType.SuccessType == Void {
        let sessionRequest : SessionType.SessionRequestType
        let creds : Credentials?
        do {
          creds = try self.credentialsContainer.fetch()
        } catch {
          completed(error)
          return
        }
        let authorizationHeaders : [String:String]
        if let creds = creds, RequestType.requiresCredentials {
          authorizationHeaders = self.builder.headers(basedOnCredentials: creds)
        } else {
          authorizationHeaders = [:]
        }
    
        let headers = self.headers.merging(authorizationHeaders) { _, rhs in
          return rhs
        }
        do {
          sessionRequest = try builder.build(request: request, withBaseURL: self.baseURLComponents, withHeaders: headers, withEncoder: self.coder)
        } catch {
          return
        }
        self.session.request(sessionRequest) { result in
          completed(result.asVoid().asError())
        }
  }
  
  var baseURLComponents: URLComponents
  let credentialsContainer = CredentialsContainer()
  
  internal init(baseURLComponents: URLComponents, coder: CoderType, session: SessionType, builder: RequestBuilderType, headers: [String : String]) {
    self.baseURLComponents = baseURLComponents
    self.coder = coder
    self.session = session
    self.builder = builder
    self.headers = headers
  }
//  
//  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where RequestType : ClientRequest, RequestType.SuccessType == Void {
//    let sessionRequest : SessionType.SessionRequestType
//    let creds : Credentials?
//    do {
//      creds = try self.credentialsContainer.fetch()
//    } catch {
//      completed(error)
//      return
//    }
//    let authorizationHeaders : [String:String]
//    if let creds = creds, RequestType.requiresCredentials {
//      authorizationHeaders = self.builder.headers(basedOnCredentials: creds)
//    } else {
//      authorizationHeaders = [:]
//    }
//    
//    let headers = self.headers.merging(authorizationHeaders) { _, rhs in
//      return rhs
//    }
//    do {
//      sessionRequest = try builder.build(request: request, withHeaders: headers, withEncoder: self.coder)
//    } catch {
//      return
//    }
//    self.session.request(sessionRequest) { result in
//      let error : Error?
//      switch result {
//      case .failure(let resultError):
//        error = resultError
//      case .success(let response):
//        error = response.statusCode / 100 == 2 ? nil : RequestError.statusCode(response.statusCode)
//      }
//      completed(error)
//    }
//  }
//  
//  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Result<RequestType.SuccessType, Error>) -> Void) where RequestType : ClientRequest, RequestType.SuccessType : Codable {
//    let sessionRequest : SessionType.SessionRequestType
//    let creds : Credentials?
//    do {
//      creds = try self.credentialsContainer.fetch()
//    } catch {
//      completed(.failure(error))
//      return
//    }
//    let authorizationHeaders : [String:String]
//    if let creds = creds, RequestType.requiresCredentials {
//      authorizationHeaders = self.builder.headers(basedOnCredentials: creds)
//    } else {
//      authorizationHeaders = [:]
//    }
//    
//    let headers = self.headers.merging(authorizationHeaders) { _, rhs in
//      return rhs
//    }
//    do {
//      sessionRequest = try builder.build(request: request, withHeaders: headers, withEncoder: self.coder)
//    } catch {
//      return
//    }
//    self.session.request(sessionRequest) { result in
//      
//      let decodedResult :  Result<RequestType.SuccessType, Error> = result.flatMap { data in
//        guard let bodyData = data.data else {
//          return Result<RequestType.SuccessType, Error>.failure(RequestError.missingData)
//        }
//        
//        return Result {
//          try self.coder.decode(RequestType.SuccessType.self, from: bodyData)
//        }
//      }
//      completed(decodedResult)
//    }
//  }
  
  //  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where RequestType : ClientBaseRequest {
  //    let sessionRequest : SessionType.SessionRequestType
  //    do {
  //     sessionRequest = try builder.build(request: request, withHeaders: headers, withEncoder: self.coder)
  //    } catch {
  //      return
  //    }
  //    self.session.request(sessionRequest) { result in
  //      let error : Error?
  //      switch result {
  //      case .failure(let resultError):
  //        error = resultError
  //      case .success(let response):
  //        error = response.statusCode / 100 == 2 ? nil : RequestError.statusCode(response.statusCode)
  //      }
  //      completed(error)
  //    }
  //  }
  //
  //  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Result<RequestType.SuccessType, Error>) -> Void) where RequestType : ClientSuccessRequest {
  //    let sessionRequest : SessionType.SessionRequestType
  //    do {
  //     sessionRequest = try builder.build(request: request, withHeaders: headers, withEncoder: self.coder)
  //    } catch {
  //      return
  //    }
  //    self.session.request(sessionRequest) { result in
  //
  //      let decodedResult :  Result<RequestType.SuccessType, Error> = result.flatMap { data in
  //        guard let bodyData = data.data else {
  //                return Result<RequestType.SuccessType, Error>.failure(RequestError.missingData)
  //              }
  //              return Result {
  //                try self.coder.decode(RequestType.SuccessType.self, from: bodyData)
  //              }
  //            }
  //            completed(decodedResult)
  //    }
  //  }
  //
  //  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where RequestType : ClientBodyRequest {
  //    let sessionRequest : SessionType.SessionRequestType
  //    do {
  //     sessionRequest = try builder.build(request: request, withHeaders: headers, withEncoder: self.coder)
  //    } catch {
  //      return
  //    }
  //    self.session.request(sessionRequest) { result in
  //      let error : Error?
  //      switch result {
  //      case .failure(let resultError):
  //        error = resultError
  //      case .success(let response):
  //        error = response.statusCode / 100 == 2 ? nil : RequestError.statusCode(response.statusCode)
  //      }
  //      completed(error)
  //    }
  //  }
  //
  let coder : CoderType
  let session : SessionType
  let builder : RequestBuilderType
  
  let headers : [String : String]
  //
  //  public func beginRequest<RequestType : ClientBodySuccessRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void) {
  //    let sessionRequest : SessionType.SessionRequestType
  //    do {
  //     sessionRequest = try builder.build(request: request, withHeaders: headers, withEncoder: self.coder)
  //    } catch {
  //      return
  //    }
  //    self.session.request(sessionRequest) { result in
  //
  //      let decodedResult :  Result<RequestType.SuccessType, Error> = result.flatMap { data in
  //        guard let bodyData = data.data else {
  //                return Result<RequestType.SuccessType, Error>.failure(RequestError.missingData)
  //              }
  //              return Result {
  //                try self.coder.decode(RequestType.SuccessType.self, from: bodyData)
  //              }
  //            }
  //            completed(decodedResult)
  //    }
  //
  //  }
  
  
  
  
  
  
  
}

public struct URLSessionResponse : SessionResponse {
  internal init?(urlResponse: URLResponse?, data: Data?) {
    guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
      return nil
    }
    self.httpURLResponse = httpURLResponse
    self.data = data
  }
  
  public var statusCode: Int {
    httpURLResponse.statusCode
  }
  
  
  public typealias DataType = Data
  
  public let httpURLResponse : HTTPURLResponse
  
  public let data : Data?
  
}

public protocol SessionTask {
  
}

extension URLSessionTask : SessionTask {
  
}

extension URLSession : Session {
  public func request(_ request: URLRequest, _ completed: @escaping (Result<URLSessionResponse, Error>) -> Void) -> SessionTask {
    let task = self.dataTask(with: request) { data, response, error in
      let result : Result<URLSessionResponse, Error>
      if let error = error {
        result = .failure(error)
      } else if let sessionResponse = URLSessionResponse(urlResponse: response, data: data) {
        result = .success(sessionResponse)
      } else {
        result = .failure(RequestError.invalidResponse(response))
      }
      completed(result)
    }
    task.resume()
    return task
  }
  
  
  public typealias SessionRequestType = URLRequest
  
  public typealias SessionResponseType = URLSessionResponse
  
  
}

struct JSONCoder : Coder {
  func encode<CodableType>(_ value: CodableType) throws -> Data where CodableType : Encodable {
    try self.encoder.encode(value)
  }
  
  func decode<CodableType>(_ type: CodableType.Type, from data: Data) throws -> CodableType where CodableType : Decodable {
    try self.decoder.decode(type, from: data)
  }
  
  typealias DataType = Data
  
  internal init(encoder: JSONEncoder, decoder: JSONDecoder) {
    self.encoder = encoder
    self.decoder = decoder
  }
  
  let encoder : JSONEncoder
  let decoder : JSONDecoder
}

extension ServiceImpl {
  convenience init (baseURLComponents: URLComponents, coder: JSONCoder = .init(encoder: JSONEncoder(), decoder: JSONDecoder()), session: URLSession = .shared, headers: [String : String]) where RequestBuilderType == URLRequestBuilder, SessionType == URLSession, CoderType == JSONCoder {
    self.init(baseURLComponents: baseURLComponents, coder: coder, session: session, builder: .init(), headers: headers)
  }
}
