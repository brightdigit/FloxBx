//
//  File.swift
//  
//
//  Created by Leo Dion on 7/28/22.
//

import Foundation


#if canImport(GroupActivities)
import GroupActivities
#endif

public protocol FloxBxGroupSession {
#if canImport(GroupActivities)
  @available(iOS 15, macOS 12,  *)
  func getValue () -> GroupSession<FloxBxActivity>
  #endif
}
