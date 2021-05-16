//
//  SwiftUIView.swift
//  
//
//  Created by Leo Dion on 5/16/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
      Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/).sheet(isPresented: .constant(true), content: {
        LoginView()
      })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ContentView()
    }
}
