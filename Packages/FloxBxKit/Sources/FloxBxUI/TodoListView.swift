#if canImport(SwiftUI)
  import SwiftUI

  struct TodoListView: View {
    @EnvironmentObject var object: ApplicationObject

    var body: some View {
      List {
        ForEach(self.object.items) { item in
          TodoListItemView(item: item).onAppear {
            self.object.saveItem(item, onlyNew: true)
          }
        }.onDelete(perform: object.deleteItems(atIndexSet:))
      }
      .toolbar(content: {
        ToolbarItemGroup {
          HStack {
            Button {
              self.object.logout()
            } label: {
              Image(systemName: "person.crop.circle.fill.badge.xmark")
            }

            Button {
              #if canImport(GroupActivities)
                if #available(iOS 15, macOS 12, *) {
                  object.requestSharing()
                } else {
                  // Fallback on earlier versions
                }
              #endif
            } label: {
              Image(systemName: "shareplay")
            }

            Button {
              self.object.addItem(.init(title: "New Item"))
            } label: {
              Image(systemName: "plus.circle.fill")
            }

            #if os(iOS)

              EditButton()

            #endif
          }
        }
      })
      .navigationTitle("Todos")
    }
  }

  struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
      TodoListView().environmentObject(ApplicationObject([
        .init(title: "Do Stuff")
      ]))
    }
  }
#endif
