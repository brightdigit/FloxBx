//
//  File.swift
//  
//
//  Created by Leo Dion on 10/24/22.
//
#if canImport(SwiftUI) && canImport(UIKit) && canImport(GroupActivities)

import SwiftUI
import UIKit
import GroupActivities

@available(iOS 15.4, *)
struct GroupActivitySharingView<ActivityType : GroupActivity> : UIViewControllerRepresentable {
  internal init(activity: ActivityType) throws {
    self.controller = try GroupActivitySharingController(activity)
  }
  
  let controller : GroupActivitySharingController
  
  
  func makeUIViewController(context: Context) -> GroupActivitySharingController {
    return controller
    
    
  }
  
  func updateUIViewController(_ uiViewController: GroupActivitySharingController, context: Context) {
    
  }
  
  typealias UIViewControllerType = GroupActivitySharingController
  
  
}
#endif
