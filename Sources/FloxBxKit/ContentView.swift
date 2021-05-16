//
//  SwiftUIView.swift
//  
//
//  Created by Leo Dion on 5/16/21.
//

import SwiftUI

struct ContentView: View {
  @EnvironmentObject var object: ApplicationObject
  
    var body: some View {
      
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/).frame(width: 500, height: 500, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
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
