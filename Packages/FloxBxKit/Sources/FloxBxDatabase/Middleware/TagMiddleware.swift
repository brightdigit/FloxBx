import FluentKit
import Foundation
//
// extension String {
//  public func slugified(
//    separator: String = "-",
//    // swiftlint:disable:next line_length
//    allowedCharacters: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
//  ) -> String {
//    lowercased()
//      .components(separatedBy: allowedCharacters.inverted)
//      .filter { $0 != "" }
//      .joined(separator: separator)
//  }
// }

internal struct TagMiddleware: AsyncModelMiddleware {
  internal typealias Model = Tag

  internal func create(
    model: Tag,
    on db: Database,
    next: AnyAsyncModelResponder
  ) async throws {
    model.id = model.id?.slugified()
    try await next.create(model, on: db)
  }

  internal func update(
    model: Tag,
    on db: Database,
    next: AnyAsyncModelResponder
  ) async throws {
    model.id = model.id?.slugified()
    try await next.update(model, on: db)
  }
}
