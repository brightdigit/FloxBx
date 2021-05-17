//
//  File.swift
//  
//
//  Created by Leo Dion on 5/16/21.
//

import Combine
import SwiftUI

public struct Credentials {
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
  static let server = "www.example.com"
  public init () {
    #if os(macOS)
    self.requiresAuthentication = false
    #else
    self.requiresAuthentication = true
    #endif
  }
  
  public func begin() throws {
    #if os(macOS)
    self.requiresAuthentication = true
    #endif
    let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                kSecAttrServer as String: ApplicationObject.server,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecReturnAttributes as String: true,
                                kSecReturnData as String: true]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { throw KeychainError.noPassword }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    guard let existingItem = item as? [String : Any],
        let passwordData = existingItem[kSecValueData as String] as? Data,
        let password = String(data: passwordData, encoding: String.Encoding.utf8),
        let account = existingItem[kSecAttrAccount as String] as? String
    else {
        throw KeychainError.unexpectedPasswordData
    }
    let credentials = Credentials(username: account, password: password)
  }
  
  public func beginSignup() {
//    let request = URLRequest
//    URLSession.shared.dataTask(with: <#T##URLRequest#>)
  }
  
  public func beginSignIn(withCredentials credentials: Credentials) throws {
    let account = credentials.username
    let password = credentials.password.data(using: String.Encoding.utf8)!
    var query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                kSecAttrAccount as String: account,
                                kSecAttrServer as String: ApplicationObject.server,
                                kSecValueData as String: password]
    
    // on success
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
  }
}
