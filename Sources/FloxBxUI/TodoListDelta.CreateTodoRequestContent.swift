//
//  File.swift
//  
//
//  Created by Leo Dion on 7/28/22.
//

import Foundation
import FloxBxModels
import FloxBxGroupActivities

public extension TodoListDelta {
  static func upsert (_ id: UUID, _ content: CreateTodoRequestContent) -> Self {
    return .upsert(id, ItemContent(title: content.title))
  }
}

