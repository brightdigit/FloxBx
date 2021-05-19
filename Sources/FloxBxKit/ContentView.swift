//
//  SwiftUIView.swift
//  
//
//  Created by Leo Dion on 5/16/21.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var object: ApplicationObject
  
  var innerView: some View {
    let view = Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    #if os(macOS)
      return view.frame(width: 500, height: 500)
    #else
    return view
    #endif
    
  }
    var body: some View {
      TabView{
        NavigationView{
          innerView
        }
      }
        .sheet(isPresented: self.$object.requiresAuthentication, content: {
        LoginView()
        }).onAppear(perform: {
          #if os(macOS)
          try? self.object.begin()
          #endif
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
}