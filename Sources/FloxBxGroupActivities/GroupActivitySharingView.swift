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
public struct GroupActivitySharingView<ActivityType : GroupActivity> : UIViewControllerRepresentable {
  public init(activity: ActivityType) {
    print("viewing ", activity)
    self.controller = try! GroupActivitySharingController(activity)
  }
  
  let controller : GroupActivitySharingController
  
  
  public func makeUIViewController(context: Context) -> GroupActivitySharingController {
    return controller
    
    
  }
  
  public func updateUIViewController(_ uiViewController: GroupActivitySharingController, context: Context) {
    
  }
  
  public typealias UIViewControllerType = GroupActivitySharingController
  
  
}
#endif
