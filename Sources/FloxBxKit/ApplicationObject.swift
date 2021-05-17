//
//  File.swift
//  
//
//  Created by Leo Dion on 5/16/21.
//

import Combine
import SwiftUI

struct Credentials {
    var username: String
    var password: String
}

enum KeychainError: Error {
    case noPassword
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

public class ApplicationObject: ObservableObject {
  @Published public var token : String? = nil
  @Published public var requiresAuthentication: Bool
  
  public init () {
    #if os(macOS)
    self.requiresAuthentication = false
    #else
    self.requiresAuthentication = true
    #endif
  }
  
  public func begin(){
    #if os(macOS)
    self.requiresAuthentication = true
    #endif
  }
  
  public func beginSignup() {
    
  }
}
