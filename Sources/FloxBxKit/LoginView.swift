//
//  ContentView.swift
//  Shared
//
//  Created by Leo Dion on 5/10/21.
//

import SwiftUI

#if os(watchOS)
typealias FBTextFieldStyle = DefaultTextFieldStyle
#else
typealias FBTextFieldStyle = RoundedBorderTextFieldStyle
#endif

#if os(watchOS)
typealias FBButtonStyle = DefaultButtonStyle
#else
typealias FBButtonStyle = BorderlessButtonStyle
#endif


public struct LoginView: View {
  @EnvironmentObject var object: ApplicationObject
  @State var emailAddress : String = ""
  
  @State var password : String = ""
  
  
  public init () {}
  
    public var body: some View {
      VStack{
        #if !os(watchOS)
        Spacer()
        Image("Logo").resizable().scaledToFit().layoutPriority(-1)
        Text("FloxBx").font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/).fontWeight(.ultraLight).padding()
        Spacer()
        #endif
        VStack{
        TextField("Email Address", text: $emailAddress).textFieldStyle(FBTextFieldStyle())
        SecureField("Password", text: $password).textFieldStyle(FBTextFieldStyle())
        }.padding()
        
          #if os(watchOS)
          Button(action: {}, label: {
            Text("Get Started").fontWeight(.bold)
          })
          #else
          HStack{
            Button(action: {
              self.object.beginSignIn(withCredentials: .init(username: self.emailAddress, password: self.password))
            }, label: {
              Text("Sign In").fontWeight(.light)
            }).buttonStyle(FBButtonStyle())
          Spacer()
            Button(action: {
              self.object.beginSignup(withCredentials: .init(username: self.emailAddress, password: self.password))
            }, label: {
              Text("Sign Up").fontWeight(.bold)
            })
          }.padding()
          #endif
        Spacer()
      }.padding().frame(maxWidth: 300,  maxHeight: 500)
    }
}

public struct LoginView_Previews: PreviewProvider {
  public static var previews: some View {
      ForEach(ColorScheme.allCases, id: \.self) {
           LoginView().preferredColorScheme($0)
      }
  }
}
