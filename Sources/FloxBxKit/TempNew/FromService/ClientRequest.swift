public protocol ClientRequest: ClientBaseRequest {
  associatedtype SuccessType
  associatedtype BodyType

  var body: BodyType { get }
}
