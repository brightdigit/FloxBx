//
//  File.swift
//  
//
//  Created by Leo Dion on 7/28/22.
//

import Foundation
import Combine

#if canImport(GroupActivities)
import GroupActivities
#endif



public class SharePlayObject : ObservableObject{
  @Published public  private(set) var listDeltas = [TodoListDelta]()
  @Published public  private(set) var groupSessionID : UUID?
  private let startSharingSubject = PassthroughSubject<Void, Never>()
  private let messageSubject = PassthroughSubject<[TodoListDelta], Never>()
  private var tasks = Set<Task<Void, Never>>()
  private var subscriptions = Set<AnyCancellable>()
  
  public func configureGroupSession(_ groupSessionWrapped: FloxBxGroupSession) {
    if #available(iOS 15, macOS 12, *) {
#if canImport(GroupActivities)
      let groupSession = groupSessionWrapped.getValue()
      self.configureGroupSession(groupSession)
#else
      return
#endif
    } else {
      return
    }
  }
  
  public init () {
#if canImport(GroupActivities)
    if #available(iOS 15, macOS 12, *) {
      self.$session.compactMap {
        $0 as? GroupSession<FloxBxActivity>
        
      }.map {
        $0.activity.id as UUID?
      }.assign(to: &self.$groupSessionID)
    }
#endif
  }
  
#if canImport(GroupActivities)
  @Published var session: Any?
 
 private(set) lazy var messenger: Any? = nil
  
  
  @available(iOS 15,macOS 12,  *)
  public func configureGroupSession(_ groupSession: GroupSession<FloxBxActivity>) {
    
    listDeltas = []

      self.groupSession = groupSession

      let messenger = GroupSessionMessenger(session: groupSession)
      self.messenger = messenger

      self.groupSession?.$state
          .sink(receiveValue: { state in
              if case .invalidated = state {
                  self.groupSession = nil
                  self.reset()
              }
          }).store(in: &subscriptions)

      self.groupSession?.$activeParticipants
          .sink(receiveValue: { activeParticipants in
              let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)

              Task {
                  // try? await messenger.send(CanvasMessage(strokes: self.strokes, pointCount: self.pointCount), to: .only(newParticipants))
                  try? await messenger.send(self.listDeltas, to: .only(newParticipants))
              }
          }).store(in: &subscriptions)
      let task = Task {
          for await(message, _) in messenger.messages(of: [TodoListDelta].self) {
            messageSubject.send(message)
              //handle(message)
          }
      }
      tasks.insert(task)

      groupSession.join()
  }
  
  @available(macOS 12, iOS 15, *)
  var groupSession: GroupSession<FloxBxActivity>? {
    get {
      return session as? GroupSession<FloxBxActivity>
    }
    set {
      self.session = newValue
    }
  }

  @available(macOS 12, iOS 15, *)
  var groupSessionMessenger: GroupSessionMessenger? {
    self.messenger as? GroupSessionMessenger
  }
  
  
  @available(macOS 12, iOS 15, *)
  public func sessions () -> GroupSession<FloxBxActivity>.Sessions {
    return FloxBxActivity.sessions()
  }
  
  @available(macOS 12, iOS 15, *)
  public func activity (forGroupSessionWithID groupSessionID: UUID, withUserName username: String) async throws -> FloxBxActivity {
    
    let activity = FloxBxActivity(id: groupSessionID ,username: username)
    _ = try await activity.activate()
    return activity
  }
  #endif
  
  func reset() {
    if #available(macOS 12, iOS 15, *){
#if canImport(GroupActivities)
      // Clear local drawing canvas.
      
      listDeltas = []
      
      // Teardown existing groupSession.
      messenger = nil
      tasks.forEach { $0.cancel() }
      tasks = []
      subscriptions = []
      if groupSession != nil {
        groupSession?.leave()
        groupSession = nil
        self.startSharingSubject.send()
      }
#endif
    }
  }
  
  public var messagePublisher : AnyPublisher<[TodoListDelta], Never> {
    self.messageSubject.eraseToAnyPublisher()
  }
  
  public var startSharingPublisher : AnyPublisher<Void, Never> {
    self.startSharingSubject.eraseToAnyPublisher()
  }
  
  public func send (_ deltas: [TodoListDelta]) {
#if canImport(GroupActivities)
            if #available(iOS 15, macOS 12, *) {
                if let groupSessionMessenger = self.groupSessionMessenger {
                    Task {
                        try? await groupSessionMessenger.send(deltas)
                    }
                }
            }
    #endif
  }
  
  public func append(delta: TodoListDelta) {
    DispatchQueue.main.async {
      self.listDeltas.append(delta)
    }
  }
  
  
  
  

}