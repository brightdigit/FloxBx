#if canImport(SwiftUI)
  import SwiftUI

  struct TodoListView: View {
    @EnvironmentObject var object: ApplicationObject

    var body: some View {
      List {
        ForEach(self.object.items) { item in
          TodoListItemView(item: item).onAppear { self.object.saveItem(item, onlyNew: true)
          }
        }.onDelete(perform: object.deleteItems(atIndexSet:))
      }
      .toolbar(content: {
        ToolbarItemGroup {
          HStack {
            #if os(iOS)

              EditButton()

            #endif

            Button {
              self.object.items.append(.init(title: "New Item"))
            } label: {
              Image(systemName: "plus.circle.fill")
            }
          }
        }
      })
      .navigationTitle("Todos")
    }
  }

  struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
      TodoListView().environmentObject(ApplicationObject(items: [
        .init(title: "Do Stuff")
      ]))
    }
  }
#endif
