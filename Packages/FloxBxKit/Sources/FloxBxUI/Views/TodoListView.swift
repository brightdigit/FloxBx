#if canImport(SwiftUI)
  import Combine
  import FloxBxModels
  import Prch
  import SwiftUI

  internal struct TodoListView: View {
    let onLogout: () -> Void
    let requestSharing: () -> Void
    @StateObject private var listObject: TodoListObject
    @StateObject var authorization: AuthorizationObject

    init(
      groupActivityID: UUID?,
      service: any AuthorizedService,
      items: [TodoContentItem] = [],
      isLoaded: Bool? = nil,
      onLogout: @escaping () -> Void,
      requestSharing: @escaping () -> Void
    ) {
      let isLoaded = isLoaded ?? !items.isEmpty
      self.onLogout = onLogout
      self.requestSharing = requestSharing
      _authorization = .init(wrappedValue: .init(service: service))
      _listObject = StateObject(
        wrappedValue: .init(
          groupActivityID: groupActivityID,
          service: service,
          isLoaded: isLoaded
        )
      )
    }

    private var list: some View {
      List {
        ForEach(self.listObject.items) { item in
          TodoListItemView(
            item: item,
            groupActivityID: listObject.groupActivityID,
            service: listObject.service
          ).onAppear {
            self.listObject.saveItem(item, onlyNew: true)
          }
        }.onDelete(perform: listObject.beginDeleteItems(atIndexSet:))
      }.toolbar(content: {
        ToolbarItemGroup {
          HStack {
            Button {
              self.authorization.logout()
            } label: {
              Image(systemName: "person.crop.circle.fill.badge.xmark")
            }

            Button {
              #if canImport(GroupActivities)
                if #available(iOS 15, macOS 12, *) {
                  self.requestSharing()
                }
              #endif
            } label: {
              Image(systemName: "shareplay")
            }

            Button {
              self.listObject.addItem(.init(title: "New Item", tags: []))
            } label: {
              Image(systemName: "plus.circle.fill")
            }

            #if os(iOS)
              EditButton()
            #endif
          }
        }
      })
    }

    internal var body: some View {
      Group {
        if self.listObject.isLoaded {
          list
        } else {
          ProgressView()
        }
      }
      .onAppear {
        self.listObject.begin()
      }
      .onReceive(self.authorization.$account, perform: { account in
        if account == nil {
          self.onLogout()
        } else {
          self.listObject.begin()
        }
      })
      .navigationTitle("Todos")
    }
  }

  internal struct TodoList_Previews: PreviewProvider {
    // swiftlint:disable:next strict_fileprivate
    internal static var previews: some View {
      TodoListView(
        groupActivityID: nil,
        service: PreviewService(
          todoItems: [
            CreateTodoResponseContent(id: .init(), title: "Cheese", tags: [])
          ]),
        isLoaded: true
      ) {} requestSharing: {
      }
    }
  }
#endif
