public enum EncodableValue {
  case encodable(Encodable)
  case empty
}

public protocol ContentEncodable {
  var encodable : EncodableValue { get }
}

public protocol ContentDecodable {
  associatedtype DecodableType 
  static var decodable : DecodableType.Type { get }
  init(decoded : DecodableType) throws
  static func decode<CoderType: Coder>(_ data: CoderType.DataType, using coder: CoderType) throws -> DecodableType
  
}

public typealias Content = ContentEncodable & ContentDecodable

extension Encodable where Self : ContentEncodable {
  public var encodable : EncodableValue {
    return .encodable(self)
  }
}
extension Decodable where Self : ContentDecodable, DecodableType == Self {
    public static var decodable : Self.Type {
    return Self.self
  }
  public init(decoded : DecodableType) throws {

    self = decoded
  }
  
  public static func decode<CoderType>(_ data: CoderType.DataType, using coder: CoderType) throws -> Self where CoderType : FloxBxModeling.Coder {
    try coder.decode(Self.self, from: data)
  }
}

extension Array : ContentDecodable where Element : ContentDecodable & Decodable, Element.DecodableType == Element {
  public static func decode<CoderType>(_ data: CoderType.DataType, using coder: CoderType) throws -> Array<Element.DecodableType> where CoderType : Coder {
    try coder.decode([Element.DecodableType].self, from: data)
  }
  
  public static var decodable: Array<Element.DecodableType>.Type {
    return Self.self
  }
  
  public init(decoded: Array<Element.DecodableType>) throws {

    self = decoded
  }
  
  public typealias DecodableType = Array<Element.DecodableType>
  
  
}
