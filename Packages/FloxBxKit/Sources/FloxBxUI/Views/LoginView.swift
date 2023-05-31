#if canImport(SwiftUI)
  import SwiftUI

  internal struct LoginView: View {
    internal init(service: any AuthorizedService, completed: @escaping () -> Void) {
      self.completed = completed
      _authorization = .init(wrappedValue: .init(service: service))
    }

    func logout() {
      authorization.logout()
    }

    let completed: () -> Void
    @StateObject var authorization: AuthorizationObject
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isAlertPresented: Bool = false
    #if os(watchOS)
      @State private var presentLoginOrSignup = false
    #endif

    private var logoTitleView: some View {
      Group {
        Spacer()
        Image("Logo").resizable().scaledToFit().layoutPriority(-1)
        Text("FloxBx")
          .font(/*@START_MENU_TOKEN@*/ .title/*@END_MENU_TOKEN@*/)
          .fontWeight(.ultraLight)
          .padding()
        Spacer()
      }
    }

    private var loginForm: some View {
      VStack {
        TextField("Email Address", text: $emailAddress)
          .textFieldStyle(FBTextFieldStyle())
          .forEmailAddress()

        SecureField("Password", text: $password).textFieldStyle(FBTextFieldStyle())
      }.padding()
    }

    private var formButtons: some View {
      HStack {
        Button(action: {
          self.authorization.beginSignIn(
            withCredentials: .init(
              username: self.emailAddress,
              password: self.password
            )
          )
        }, label: {
          Text("Sign In").fontWeight(.light)
        }).buttonStyle(FBButtonStyle())
        Spacer()
        Button(
          action: {
            self.authorization.beginSignup(
              withCredentials: .init(
                username: self.emailAddress,
                password: self.password
              )
            )
          }, label: {
            Text("Sign Up").fontWeight(.bold)
          }
        )
      }.padding()
    }

    private var content: some View {
      VStack {
        #if !os(watchOS)
          logoTitleView
        #endif
        loginForm

        #if os(watchOS)
          Button(action: {
            self.presentLoginOrSignup = true
          }, label: {
            Text("Get Started")
              .fontWeight(.bold)
          })
        #else
          formButtons
        #endif
        Spacer()
      }
      .padding()
      .frame(maxWidth: 300, maxHeight: 500)
      .onReceive(self.authorization.$account) { account in
        guard account != nil else {
          return
        }
        self.completed()
      }
    }

    internal var body: some View {
      #if os(watchOS)
        self.content.sheet(
          isPresented: self.$presentLoginOrSignup,
          content: self.watchForm
        )
      #else

        self.content.alert(
          isPresented: .constant(self.authorization.error != nil),
          error: self.authorization.error
        ) {
          Button("OK") {
            Task { @MainActor in
              self.isAlertPresented = false
            }
          }
        }

      #endif
    }

    private func watchForm() -> some View {
      VStack {
        Text("Sign up new account or sign in existing?")
        Spacer()
        Button("Sign Up") {
          self.authorization
            .beginSignup(
              withCredentials: .init(
                username: self.emailAddress,
                password: self.password
              )
            )
        }
        Button("Sign In") {
          self.authorization.beginSignIn(
            withCredentials: .init(
              username: self.emailAddress,
              password: self.password
            )
          )
        }
      }
    }
  }

  internal struct LoginView_Previews: PreviewProvider {
    internal static var previews: some View {
      ForEach(ColorScheme.allCases, id: \.self) {
        LoginView(service: PreviewService()) {}.preferredColorScheme($0)
      }
    }
  }
#endif
