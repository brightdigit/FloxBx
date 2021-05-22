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
      List(self.object.items ?? .init()) { item in
        Text(item.title)
      }
    }
}

struct TodoList_Previews: PreviewProvider {
    static var previews: some View {
      TodoList().environmentObject(ApplicationObject(items: [
        .init(title: "Do Stuff")
      ]))
    }
}
