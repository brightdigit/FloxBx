//
//  File.swift
//  
//
//  Created by Leo Dion on 1/23/23.
//

import Foundation


extension CheckedContinuation where T == Void {
  public func resume(with error: E?) {
    if let error = error {
      return resume(throwing: error)
    } else {
      return resume()
    }
  }
}
