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


public struct ContentView: View {
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
        
        Button(action: {}, label: {
          Text("Sign Up").fontWeight(.bold)
        })
        Button(action: {}, label: {
          Text("Sign In").fontWeight(.light)
        }).buttonStyle(FBButtonStyle())
        Spacer()
      }.padding()
    }
}

public struct ContentView_Previews: PreviewProvider {
  public static var previews: some View {
      ForEach(ColorScheme.allCases, id: \.self) {
           ContentView().preferredColorScheme($0)
      }
  }
}
