//
//  SwiftUIView.swift
//  
//
//  Created by Leo Dion on 2/3/23.
//

import Foundation
import Combine
import FloxBxAuth
import FloxBxNetworking
import FloxBxRequests

struct AuthenticationError : LocalizedError {
  internal init(innerError: Error) {
    self.innerError = innerError
  }
  
  let innerError : Error
  

  
  var errorDescription: String? {
    return innerError.localizedDescription
  }
}

class AuthorizationObject: ObservableObject {
  internal init(service: any AuthorizedService, account: Account? = nil) {
    self.service = service
    self.account = account
    
    let refreshPublisher = refreshSubject.map {
      Future{
        try await self.service.fetchCredentials()
      }
    }
    .switchToLatest()
    .compactMap{$0}
    .map{Account(username: $0.username)}
    .mapError(AuthenticationError.init)
    .share()
    
    refreshPublisher.map(Optional.some).catch{_ in Just(Optional.none)}.compactMap{$0}.subscribe(self.accountSubject).store(in: &self.cancellables)
    
    refreshPublisher.map{_ in Optional<AuthenticationError>.none}.catch{Just(Optional.some($0))}.compactMap{$0}.subscribe(self.errorSubject).store(in: &self.cancellables)
      
    
    //successfulCompletedSubject.map(Optional.some).receive(on: DispatchQueue.main).assign(to: &self.$account)
    
    let logoutCompleted = self.logoutCompletedSubject.share()
    
    logoutCompleted.compactMap{
      (try? $0.get()).map {
        return nil
      }
    }
    .subscribe(self.accountSubject).store(in: &self.cancellables)
    
    
    logoutCompleted.compactMap {
      $0.asError().map(AuthenticationError.init)
    }.subscribe(self.errorSubject).store(in: &self.cancellables)
    
    
    let authenticationResult = authenticateSubject.map { (credentials, isNew) in
      return Future { ()  async throws -> Credentials in
        let token : String
        if isNew {
          token = try await self.service.request(SignUpRequest(body: .init(emailAddress: credentials.username, password: credentials.password))).token
        } else {
          token = try await self.service.request(SignInCreateRequest(body: .init(emailAddress: credentials.username, password: credentials.password))).token
        }
        return credentials.withToken(token)
      }
    }
    .switchToLatest()
    .tryMap { credentials in
      try self.service.save(credentials: credentials)
      return Account(username: credentials.username)
    }
    .share()
    //.share()
    
    authenticationResult.map(Optional.some).catch{_ in Just(Optional.none)}.compactMap{$0}.subscribe(self.accountSubject).store(in: &self.cancellables)
    authenticationResult.mapError(AuthenticationError.init).map{_ in Optional<AuthenticationError>.none}.catch{Just(Optional.some($0))}.compactMap{$0}.subscribe(self.errorSubject).store(in: &self.cancellables)
    
    errorSubject.map(Optional.some).receive(on: DispatchQueue.main).assign(to: &self.$error)
    accountSubject.receive(on: DispatchQueue.main).assign(to: &self.$account)
  }
  
  
  let service : any AuthorizedService
  @Published var account: Account?
  @Published var error : AuthenticationError?
  let logoutCompletedSubject = PassthroughSubject<Result<Void, Error>, Never>()
  let authenticateSubject = PassthroughSubject<(Credentials, Bool), Never>()
  let refreshSubject = PassthroughSubject<Void, Never>()
  let errorSubject = PassthroughSubject<AuthenticationError, Never>()
  let accountSubject = PassthroughSubject<Account?, Never>()
  
  var cancellables = [AnyCancellable]()
  
  
  internal func beginSignup(withCredentials credentials: Credentials) {
    self.authenticateSubject.send((credentials, true))
  }
  
  func beginSignIn(withCredentials credentials: Credentials) {
    self.authenticateSubject.send((credentials, false))
  }
  
  func logout () {
    let result = Result{
      try service.resetCredentials()
    }
    self.logoutCompletedSubject.send(result)
  }
}
