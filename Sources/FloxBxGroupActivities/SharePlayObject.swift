public enum GroupActivitiesError : Error {
  case invalidActivity(Any)
}

public struct GroupActivityConfiguration {
  public init(groupSessionID: UUID, username: String) {
    self.groupSessionID = groupSessionID
    self.username = username
  }
  
 let groupSessionID: UUID
  let username: String
}

public enum ActivationResult {

    case activationPreferred
    case activationDisabled
    case cancelled

}


extension Future where Failure == Error {
    convenience init(_ asyncFunc: @escaping () async throws -> Output) {
        self.init { promise in
            Task {
                do {
                    let result = try await asyncFunc()
                    promise(.success(result))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }
}
extension Future where Failure == Never {
    convenience init(_ asyncFunc: @escaping () async -> Output) {
        self.init { promise in
            Task {
              promise(.success(await asyncFunc()))
            }
        }
    }
}
#if canImport(Combine)
  import Combine
  import Foundation

  #if canImport(GroupActivities)
    import GroupActivities

public struct FloxBxActivityIdentifiableContainer : Identifiable {
  public var id: UUID {
    if #available(iOS 15, *) {
      guard let actvitiy = activity as? FloxBxActivity else {
        preconditionFailure()
      }
      return actvitiy.id
    } else {
      preconditionFailure()
      // Fallback on earlier versions
    }
  }
  
  let activity : Any
  
  @available(iOS 15, *)
  public var groupActivity : FloxBxActivity {
    
      guard let actvitiy = activity as? FloxBxActivity else {
        preconditionFailure()
      }
    return actvitiy
  }
  
  @available(iOS 15, *)
  init(activity: FloxBxActivity) {
    self.activity = activity
  }
}

  #endif

  public class SharePlayObject<DeltaType: Codable>: ObservableObject {
    @Published public private(set) var listDeltas = [DeltaType]()
    @Published public private(set) var groupSessionID: UUID?
    
    private let startSharingSubject = PassthroughSubject<Void, Never>()
    private let activityConfigurationSubject = PassthroughSubject<GroupActivityConfiguration, Never>()
    private let messageSubject = PassthroughSubject<[DeltaType], Never>()
    private var tasks = Set<Task<Void, Never>>()
    private var subscriptions = Set<AnyCancellable>()

    public func configureGroupSession(_ groupSessionWrapped: ActivityGroupSessionContainer) {
      if #available(iOS 15, macOS 12, *) {
        #if canImport(GroupActivities)
          if let groupSession = groupSessionWrapped.getValue() as? GroupSession<FloxBxActivity> {
            self.configureGroupSession(groupSession)
          }
        #else
          return
        #endif
      } else {
        return
      }
    }

    public init() {
      #if canImport(GroupActivities)
        if #available(iOS 15, macOS 12, *) {
          self.$session.compactMap {
            $0 as? GroupSession<FloxBxActivity>
          }.map {
            $0.activity.id as UUID?
          }.assign(to: &self.$groupSessionID)
          
          let activityPublisher = self.activityConfigurationSubject.map(
            FloxBxActivity.init(configuration:)
          )
            
          activityPublisher.map { activity in
            Future { () -> Result<FloxBxActivity, Error> in
              print("activating ", activity.id)
              do {
                try await activity.activate()
              } catch {
                return .failure(error)
              }
              return .success(activity)
            }
          }.switchToLatest()
            .compactMap{
              print("resulting ", $0)
              return try? $0.get()
            }
            .map(FloxBxActivityIdentifiableContainer.init(activity:))
            .receive(on: DispatchQueue.main)
            .assign(to: &self.$activity)
          
        }
      #endif
    }

    #if canImport(GroupActivities)
      @Published var session: Any?
      @Published public var activity: FloxBxActivityIdentifiableContainer?

      private(set) lazy var messenger: Any? = nil

      @available(iOS 15, macOS 12, *)
      private func configureGroupSession(_ groupSession: GroupSession<FloxBxActivity>) {
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
              try? await messenger.send(self.listDeltas, to: .only(newParticipants))
            }
          }).store(in: &subscriptions)
        let task = Task {
          for await(message, _) in messenger.messages(of: [DeltaType].self) {
            messageSubject.send(message)
          }
        }
        tasks.insert(task)

        groupSession.join()
      }

      @available(macOS 12, iOS 15, *)
      var groupSession: GroupSession<FloxBxActivity>? {
        get {
          session as? GroupSession<FloxBxActivity>
        }
        set {
          session = newValue
        }
      }
    
    

    @available(macOS 12, iOS 15, *)
    var groupActivity: FloxBxActivity? {
      get {
        return self.activity?.groupActivity
      }
      set {
        activity = newValue.map(FloxBxActivityIdentifiableContainer.init(activity:))
      }
    }

      @available(macOS 12, iOS 15, *)
      var groupSessionMessenger: GroupSessionMessenger? {
        messenger as? GroupSessionMessenger
      }

      @available(macOS 12, iOS 15, *)
      public func sessions() -> GroupSession<FloxBxActivity>.Sessions {
        FloxBxActivity.sessions()
      }

      @available(macOS 12, iOS 15, *)
      public func beginPreparingActivity(forConfiguration configuration: GroupActivityConfiguration) {
        self.activityConfigurationSubject.send(configuration)
        
        
      }
    
    
    #endif

    func reset() {
      if #available(macOS 12, iOS 15, *) {
        #if canImport(GroupActivities)
          listDeltas = []
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

    public var messagePublisher: AnyPublisher<[DeltaType], Never> {
      messageSubject.eraseToAnyPublisher()
    }

    public var startSharingPublisher: AnyPublisher<Void, Never> {
      startSharingSubject.eraseToAnyPublisher()
    }

    public func send(_ deltas: [DeltaType]) {
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

    public func append(delta: DeltaType) {
      DispatchQueue.main.async {
        self.listDeltas.append(delta)
      }
    }
  }
#endif
