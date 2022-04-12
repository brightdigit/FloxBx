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
  public func build<BodyRequestType, CoderType>(request: BodyRequestType, withHeaders headers: [String: String], withEncoder encoder: CoderType) throws -> URLRequest where BodyRequestType : ClientBodyRequest, CoderType : Coder, CoderType.DataType == Data {
    
        var componenents = URLComponents()
        componenents.path = request.path
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
  
  public typealias SessionRequestType = URLRequest
  
  
//  public func build<BodyRequestType : BodyRequest, CoderType : Coder>(request: BodyRequestType, withEncoder encoder: CoderType) -> URLRequest {
//
//    var componenents = URLComponents()
//    componenents.path = request.path
//    componenents.queryItems = request.parameters.map(URLQueryItem.init)
//
//    let url = componenents.url!
//    var urlRequest = URLRequest(url: url)
//    urlRequest.httpMethod = request.method.rawValue
//
//    for (field, value) in request.headers {
//      urlRequest.addValue(value, forHTTPHeaderField: field)
//    }
//
//    urlRequest.httpBody = encoder.encode(request.body)
//    return urlRequest
//  }
}

public protocol RequestBuilder {
  associatedtype SessionRequestType : SessionRequest
  func build<BodyRequestType : ClientBodyRequest, CoderType : Coder>(request: BodyRequestType, withHeaders headers: [String: String], withEncoder encoder: CoderType) throws -> SessionRequestType where CoderType.DataType == SessionRequestType.DataType
}

public enum RequestMethod : String {
  case POST
  case GET
}

public protocol ClientBodySuccessRequest : ClientBodyRequest, ClientSuccessRequest {
  
}
public protocol ClientBodyRequest : ClientRequest {
  associatedtype BodyType : Codable
  
  var body : BodyType { get }
}

public protocol ClientSuccessRequest : ClientRequest {
  
  associatedtype SuccessType : Codable
}
public protocol ClientRequest : Codable {
  
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
  func request(_ request: SessionRequestType, _ completed: @escaping(Result<SessionResponseType, Error>) -> Void)
}



public protocol Service {
  func beginRequest<RequestType : ClientSuccessRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void)
  
  func beginRequest<RequestType : ClientBodySuccessRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void)
  
  
  func beginRequest<RequestType : ClientBodyRequest>(_ request: RequestType, _ completed: @escaping(Error?) -> Void)
  
  
  func beginRequest<RequestType : ClientRequest>(_ request: RequestType, _ completed: @escaping(Error?) -> Void)
//  func signUp(withCredentials credentials: Credentials, _ completed: @escaping (Result<Credentials, Error>) -> Void )
//  func signIn(withCredentials credentials: Credentials, _ completed: @escaping (Result<Credentials, Error>) -> Void )
//  func deleteTodoItem(withID id: UUID, _ completed: @escaping (Error?) -> Void)
//  func saveTodoItem(_ item: TodoContentItem, forUserID userID: UUID?, _ completed: @escaping (Result<CreateTodoResponseContent, Error>) -> Void)
}

public struct ServiceImpl<CoderType : Coder, SessionType : Session, RequestBuilderType : RequestBuilder> : Service where SessionType.SessionRequestType == RequestBuilderType.SessionRequestType, RequestBuilderType.SessionRequestType.DataType == CoderType.DataType, SessionType.SessionResponseType.DataType == CoderType.DataType {
  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where RequestType : ClientRequest {
    
  }
  
  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Result<RequestType.SuccessType, Error>) -> Void) where RequestType : ClientSuccessRequest {
    
  }
  
  public func beginRequest<RequestType>(_ request: RequestType, _ completed: @escaping (Error?) -> Void) where RequestType : ClientBodyRequest {
    
  }
  
  let coder : CoderType
  let session : SessionType
  let builder : RequestBuilderType
  
  let headers : [String : String]
  
  public func beginRequest<RequestType : ClientBodySuccessRequest>(_ request: RequestType, _ completed: @escaping(Result<RequestType.SuccessType, Error>) -> Void) {
    let sessionRequest : SessionType.SessionRequestType
    do {
     sessionRequest = try builder.build(request: request, withHeaders: headers, withEncoder: self.coder)
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
  
 
  
  
  
  

}
