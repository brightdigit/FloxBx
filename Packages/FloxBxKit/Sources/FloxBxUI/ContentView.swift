#if canImport(SwiftUI)
  import FelinePine
  import FloxBxGroupActivities
  import FloxBxLogging
  import Prch
  import SwiftUI

  internal struct ContentView: View, LoggerCategorized {
    internal init() {}

//    @available(*, deprecated)
//    @EnvironmentObject private var object: ApplicationObject

    @StateObject private var shareplayObject = SharePlayObject<
      TodoListDelta, GroupActivityConfiguration, UUID
    >()

    @StateObject private var services = ServicesObject()

    #if canImport(GroupActivities)
      @State private var activity: ActivityIdentifiableContainer<UUID>?
    #endif

    @State private var shouldDisplayLoginView: Bool = false

    private var innerView: some View {
      Group {
        if let service = services.service {
          #if os(macOS)
            TodoListView(
              groupActivityID: shareplayObject.groupActivityID,
              service: service,
              onLogout: self.logout,
              requestSharing: self.requestSharing
            ).frame(width: 500, height: 500)
          #else
            TodoListView(
              groupActivityID: shareplayObject.groupActivityID,
              service: service,
              onLogout: self.logout,
              requestSharing: self.requestSharing
            )
          #endif
        } else {
          ProgressView()
        }
      }
    }

    @MainActor
    func logout() {
      shouldDisplayLoginView = true
    }

    func requestSharing() {}

    private var mainView: some View {
      TabView {
        NavigationView {
          if #available(iOS 15.0, watchOS 8.0, macOS 12, *) {
            #if canImport(GroupActivities)
              innerView.task {
                await self.shareplayObject
                  .listenForSessions(forActivity: FloxBxActivity.self)
              }
            #else
              innerView
            #endif
          } else {
            innerView
          }
        }
      }
      .sheet(isPresented: self.$shouldDisplayLoginView, content: {
        if let services = self.services.service {
          LoginView(service: services) {
            Task { @MainActor in
              self.shouldDisplayLoginView = false
            }
          }
        } else {
          ProgressView()
        }
      })
      .onReceive(self.services.$requireAuthentication) { requiresAuthentication in
        self.shouldDisplayLoginView = requiresAuthentication
      }
    }

    internal var body: some View {
      if #available(iOS 15.4, *) {
        #if canImport(GroupActivities) && os(iOS)
          mainView.sheet(
            item: self.$activity
          ) { activity in
            GroupActivitySharingView<FloxBxActivity>(
              activity: activity.getGroupActivity()
            )
          }
          .onReceive(self.shareplayObject.$activity, perform: { activity in
            self.activity = activity
          })
          .onAppear(perform: {
            self.services.begin()
          })

        #else
          mainView.onAppear(perform: {
            self.services.begin()
          })
        #endif
      } else {
        mainView.onAppear(perform: {
          self.services.begin()
        })
      }
    }
  }

//  private struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//      ContentView()
//    }
//  }
#endif
