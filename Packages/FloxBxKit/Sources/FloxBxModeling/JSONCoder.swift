import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
public protocol LegacyCoder  {
  associatedtype DataType

  func encode<CodableType: Encodable>(_ value: CodableType) throws -> DataType

  func decode<CodableType: Decodable>(_: CodableType.Type, from data: DataType)
    throws -> CodableType
}
public protocol Coder : LegacyCoder{
}


public extension Coder {
  
  func decodeContent<CodableType: ContentDecodable>(_: CodableType.Type, from data: DataType)
  throws -> CodableType.DecodableType {
    return try CodableType.decode(data, using: self)
  }
  
}

enum CoderError : Error {
  case missingData
  case missingDecoding
}

public struct Empty : ContentDecodable, ContentEncodable {
  public static func decode<CoderType>(_ data: CoderType.DataType, using coder: CoderType) throws -> Void where CoderType : Coder {
    return
  }
  
  public static var decodable: Void.Type {
    return Void.self
  }
  
  
  public typealias DecodableType = Void
  
  public var encodable: EncodableValue {
    return .empty
  }
  
  
  public static let value = Empty()
  
  internal init () {}
  
  public init(decoded: Void) throws {
    
  }
}
public struct JSONCoder: Coder {

  
  
  
  public typealias DataType = Data

  private let encoder: JSONEncoder
  private let decoder: JSONDecoder

  public init(encoder: JSONEncoder, decoder: JSONDecoder) {
    self.encoder = encoder
    self.decoder = decoder
  }

  public func encode<CodableType>(
    _ value: CodableType
  ) throws -> Data where CodableType: Encodable {
    try encoder.encode(value)
  }

  public func decode<CodableType>(
    _ type: CodableType.Type,
    from data: Data
  ) throws -> CodableType where CodableType: Decodable {
    try decoder.decode(type, from: data)
  }
}
