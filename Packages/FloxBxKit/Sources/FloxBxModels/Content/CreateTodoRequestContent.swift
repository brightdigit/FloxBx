import FloxBxUtilities
import Foundation

public struct CreateTodoRequestContent: Codable {
  public let title: String
  public let tags: [String]

  public init(title: String, tags: [String]) {
    self.title = title
    self.tags = tags
  }
}

extension CreateTodoRequestContent {
  public init(text: String) {
    let title: String
    let tags: [String]
    let splits = text.split(separator: "#", omittingEmptySubsequences: true)
    title = splits.first.map(String.init) ?? ""
    tags = splits.dropFirst().map { $0.slugified() }
    self.init(title: title, tags: tags)
  }
}
