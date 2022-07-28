//
//  File.swift
//  
//
//  Created by Leo Dion on 7/28/22.
//

import Foundation

#if canImport(GroupActivities)

import GroupActivities

@available(iOS 15, macOS 12, *)
extension GroupSession<FloxBxActivity> : FloxBxGroupSession {
  public func getValue() -> GroupSession<FloxBxActivity> {
    return self
  }
}
#endif
