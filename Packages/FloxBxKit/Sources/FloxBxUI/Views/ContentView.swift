#if canImport(SwiftUI)
  import FelinePine
  import FloxBxGroupActivities
  import FloxBxLogging
  import Prch
  import SwiftUI

  internal struct ContentView: View, LoggerCategorized {
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
        if services.isReady {
          #if os(macOS)
            TodoListView(
              groupActivityID: shareplayObject.groupActivityID,
              service: services.service,
              onLogout: self.logout,
              requestSharing: self.requestSharing
            ).frame(width: 500, height: 500)
          #else
            TodoListView(
              groupActivityID: shareplayObject.groupActivityID,
              service: services.service,
              onLogout: self.logout,
              requestSharing: self.requestSharing
            )
          #endif
        } else {
          ProgressView()
        }
      }
    }

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
        if self.services.isReady {
          LoginView(service: services.service) {
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
        #else
          mainView
        #endif
      } else {
        mainView
      }
    }

    internal init() {}

    @MainActor
    internal func logout() {
      shouldDisplayLoginView = true
    }

    internal func requestSharing() {}
  }

  internal struct ContentView_Previews: PreviewProvider {
    internal static var previews: some View {
      ContentView()
    }
  }
#endif
