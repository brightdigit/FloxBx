#if canImport(SwiftUI)
  import FloxBxModels
  import Prch
  import SwiftUI
  internal struct TodoListItemView: View {
    @StateObject private var itemObject: TodoObject

    internal var body: some View {
      Group {
        if #available(iOS 15.0, watchOS 8.0, macOS 12.0, *) {
          TextField("", text: self.$itemObject.text)
            .onSubmit(self.beginSave)
            .foregroundColor(self.itemObject.isSaved ? .primary : .secondary)
        } else {
          TextField(
            "",
            text: self.$itemObject.text,
            onEditingChanged: self.beginSave(hasFinished:),
            onCommit: self.beginSave
          )
        }
      }
    }

    internal init(
      item: TodoContentItem,
      groupActivityID: UUID?,
      service: any FloxBxServiceProtocol
    ) {
      _itemObject = .init(
        wrappedValue: .init(
          item: item,
          service: service,
          groupActivityID: groupActivityID
        )
      )
    }

    private func beginSave() {
      itemObject.beginSave()
    }

    private func beginSave(hasFinished: Bool) {
      guard hasFinished else {
        return
      }
      beginSave()
    }
  }

  internal struct TodoListItemView_Previews: PreviewProvider {
    // swiftlint:disable:next strict_fileprivate
    internal static var previews: some View {
      TodoListItemView(
        item: .init(
          title: "Hello",
          tags: ["world", "Leo"]
        ),
        groupActivityID: nil,
        service: PreviewService()
      )
    }
  }
#endif
