#if canImport(SwiftUI)
  import SwiftUI

  struct ContentView: View {
    @EnvironmentObject var object: ApplicationObject

    var innerView: some View {
      let view = TodoListView()
      #if os(macOS)
        return view.frame(width: 500, height: 500)
      #else
        return view
      #endif
    }

    var body: some View {
      TabView {
        NavigationView {
          innerView
        }
      }
      .sheet(isPresented: self.$object.requiresAuthentication, content: {
        LoginView()
      }).onAppear(perform: {
        self.object.begin()
      })
    }
  }

  struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
  }
#endif
