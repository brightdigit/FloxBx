import FluentKit
import Foundation

public extension String {
    
    func slugified(
        separator: String = "-",
        allowedCharacters: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-")
    ) -> String {
        self.lowercased()
            .components(separatedBy: allowedCharacters.inverted)
            .filter { $0 != "" }
            .joined(separator: separator)
    }
}

struct TagMiddleware: AsyncModelMiddleware {
  typealias Model = Tag

  func create(model: Tag, on db: Database, next _: AnyAsyncModelResponder) async throws {
    model.id = model.id?.slugified()
    return try await model.create(on: db)
  }

  func update(model: Tag, on db: Database, next: AnyAsyncModelResponder) async throws {
    model.id = model.id?.slugified()
    return try await model.update(on: db)
  }
}
