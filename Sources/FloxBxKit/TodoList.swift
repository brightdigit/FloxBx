//
//  SwiftUIView.swift
//  
//
//  Created by Leo Dion on 5/21/21.
//

import SwiftUI

struct TodoList: View {
  @EnvironmentObject var object: ApplicationObject
  
    var body: some View {
      #if os(iOS)
      List(self.object.items ?? .init()) { item in
        Text(item.title)
      }
      .navigationTitle("Todos")
      .navigationBarItems(trailing: Button("test", action: {}))
      #else
      List(self.object.items ?? .init()) { item in
        Text(item.title)
      }
      .navigationTitle("Todos")
      #endif
      
      
    }
}

struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
      TodoList().environmentObject(ApplicationObject(items: [
        .init(title: "Do Stuff")
      ]))
    }
}
