//
//  File.swift
//  
//
//  Created by Leo Dion on 5/16/21.
//

import Combine
import SwiftUI

struct EmptyError : Error {
  
}

public struct CredentialsContainer {
  func fetch () throws -> Credentials? {
    let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                kSecAttrServer as String: ApplicationObject.server,
                                kSecMatchLimit as String: kSecMatchLimitOne,
                                kSecReturnAttributes as String: true,
                                kSecReturnData as String: true]
    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else { return nil }
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    guard let existingItem = item as? [String : Any],
        let passwordData = existingItem[kSecValueData as String] as? Data,
        let password = String(data: passwordData, encoding: String.Encoding.utf8),
        let account = existingItem[kSecAttrAccount as String] as? String
    else {
        throw KeychainError.unexpectedPasswordData
    }
    
      let tokenQuery: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                  kSecAttrServer as String: ApplicationObject.server,
                                  kSecMatchLimit as String: kSecMatchLimitOne,
                                  kSecReturnAttributes as String: true,
                                  kSecReturnData as String: true]
    var tokenItem: CFTypeRef?
    let tokenStatus = SecItemCopyMatching(tokenQuery as CFDictionary, &tokenItem)
    
    if let existingItem = tokenItem as? [String : Any],
        let passwordData = existingItem[kSecValueData as String] as? Data,
        let token = String(data: passwordData, encoding: String.Encoding.utf8),
        tokenStatus == errSecSuccess
     {
      return Credentials(username: account, password: password, token: token)
    } else {
      return Credentials(username: account, password: password)
    }
  }
  
  func save (credentials: Credentials) throws {
    let account = credentials.username
    let password = credentials.password.data(using: String.Encoding.utf8)!
    let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                kSecAttrAccount as String: account,
                                kSecAttrServer as String: ApplicationObject.server,
                                kSecValueData as String: password]
    
    // on success
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    
    if let token = credentials.token?.data(using: String.Encoding.utf8) {
      
      let query: [String: Any] = [kSecClass as String: kSecClassInternetPassword,
                                  kSecAttrAccount as String: account,
                                  kSecAttrServer as String: ApplicationObject.server,
                                  kSecValueData as String: token]
      let status = SecItemAdd(query as CFDictionary, nil)
      guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
    }
  }
}

public extension Result {
  init(success: Success?, failure: Failure?, otherwise: @autoclosure () -> Failure) {
    if let failure = failure {
      self = .failure(failure)
    } else if let success = success {
      self = .success(success)
    } else {
      self = .failure(otherwise())
    }
  }
}
public struct Credentials {
  public init(username: String, password: String, token: String? = nil) {
    self.username = username
    self.password = password
    self.token = token
  }
  
    let username: String
    let password: String
  let token: String?
  
  func withToken(_ token: String) -> Credentials {
    Credentials(username: username, password: password, token: token)
  }
}

enum KeychainError: Error {
    case unexpectedPasswordData
    case unhandledError(status: OSStatus)
}

public class ApplicationObject: ObservableObject {
  @Published public var requiresAuthentication: Bool
  @Published var latestError : Error?
  let credentialsContainer = CredentialsContainer()
  
  static let server = "floxbx.work"
  public init () {
    
    self.requiresAuthentication = false
  }
  
  public func begin() {
    let credentials: Credentials?
    let error: Error?
    
    do {
      credentials = try self.credentialsContainer.fetch()
      error = nil
    } catch let caughtError {
      error = caughtError
      credentials = nil
    }
    
    self.latestError = self.latestError ?? error
    
    if let credentials = credentials {
      self.beginSignIn(withCredentials: credentials)
    } else {
      DispatchQueue.main.async {
        self.requiresAuthentication = true
      }
      
    }

  }
  
  
  public func beginSignup(withCredentials credentials: Credentials) {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    var request = URLRequest(url: URL(string: "https://breezy-lion-74.loca.lt/api/v1/users")!)
    request.httpMethod = "POST"
    request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    let body = try! encoder.encode(CreateUserRequestContent(emailAddress: credentials.username, password: credentials.password))
    request.httpBody = body
    URLSession.shared.dataTask(with: request) { data, response, error in
      
      let result : Result<Data, Error> = Result<Data, Error>(success: data, failure: error, otherwise: EmptyError())
      let decodedResult = result.flatMap { data in
        Result {
          try decoder.decode(CreateUserResponseContent.self, from: data)
        }
      }
      let credentials = decodedResult.map{ content in
        return credentials.withToken(content.token)
      }
      let savingResult = credentials.flatMap{ creds in
        Result(catching: {try self.credentialsContainer.save(credentials: creds)})
      }
      DispatchQueue.main.async {
        switch savingResult {
        case .failure(let error):
          self.latestError = error
          self.requiresAuthentication = true
        case .success:
          self.requiresAuthentication = false
        }
        
      }
    }.resume()
  }
  public func beginSignIn(withCredentials credentials: Credentials) {
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    var request = URLRequest(url: URL(string: "https://breezy-lion-74.loca.lt/api/v1/tokens")!)
    request.httpMethod = "POST"
    let body = try! encoder.encode(CreateUserRequestContent(emailAddress: credentials.username, password: credentials.password))
    request.httpBody = body
    URLSession.shared.dataTask(with: request) { data, response, error in
      
      let result : Result<Data, Error> = Result<Data, Error>(success: data, failure: error, otherwise: EmptyError())
      let decodedResult = result.flatMap { data in
        Result {
          try decoder.decode(CreateUserResponseContent.self, from: data)
        }
      }
      let credentials = decodedResult.map{ content in
        return credentials.withToken(content.token)
      }
      let savingResult = credentials.flatMap{ creds in
        Result(catching: {try self.credentialsContainer.save(credentials: creds)})
      }
      DispatchQueue.main.async {
        switch savingResult {
        case .failure(let error):
          self.latestError = error
          self.requiresAuthentication = true
        case .success:
          self.requiresAuthentication = false
        }
        
      }
    }.resume()
  }
}
