import Combine
import Foundation

#if canImport(GroupActivities)
  import GroupActivities
#endif

public class SharePlayObject<DeltaType: Codable>: ObservableObject {
  @Published internal private(set) var listDeltas = [DeltaType]()
  // @Published internal private(set) var groupSessionID: UUID?
  @Published public private(set) var activity: ActivityIdentifiableContainer<UUID>?
  private let sharingRequestSubject = PassthroughSubject<GroupActivityConfiguration, Never>()
  private let startSharingSubject = PassthroughSubject<Void, Never>()
  private let activityPreparationSubject = PassthroughSubject<GroupActivityConfiguration, Never>()
  private let messageSubject = PassthroughSubject<[DeltaType], Never>()
  private var tasks = Set<Task<Void, Never>>()
  private var subscriptions = Set<AnyCancellable>()
  private var cancellable: AnyCancellable?

  func configureGroupSession(_ groupSessionWrapped: ActivityGroupSessionContainer) {
    if #available(iOS 15, macOS 12, *) {
      #if canImport(GroupActivities)
        let groupSession: GroupSession<FloxBxActivity> = groupSessionWrapped.getValue()
        self.configureGroupSession(groupSession)
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
//                self.$session.compactMap {
//                    $0 as? GroupSession<FloxBxActivity>
//                }.map {
//                    $0.activity.id as UUID?
//                }.assign(to: &self.$groupSessionID)

        self.cancellable = self.sharingRequestSubject.subscribe(self.activityPreparationSubject)

        self.activityPreparationSubject.map {
          FloxBxActivity(configuration: $0)
        }.map { activity in
          Future { () -> Result<FloxBxActivity, Error> in
            do {
              _ = try await activity.activate()
            } catch {
              return .failure(error)
            }
            return .success(activity)
          }
        }.switchToLatest()
          .compactMap {
            self.isEligible ? nil : try? $0.get()
          }
          .map(ActivityIdentifiableContainer.init(activity:))
          .receive(on: DispatchQueue.main)
          .assign(to: &self.$activity)
      }
    #endif
  }

  var isEligible: Bool {
    #if canImport(GroupActivities)
      return groupState.isEligible
    #else
      return false
    #endif
  }

  #if canImport(GroupActivities)
    @Published var session: Any?
    @Published var groupState = GroupStateContainer()

    private(set) lazy var messenger: Any? = nil

    @available(iOS 15, macOS 12, *)
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
            do {
              try await messenger.send(self.listDeltas, to: .only(newParticipants))
            } catch {}
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
      activity?.getGroupActivity()
    }

    @available(macOS 12, iOS 15, *)
    var groupSessionMessenger: GroupSessionMessenger? {
      messenger as? GroupSessionMessenger
    }

    @available(macOS 12, iOS 15, *)
    public func sessions() -> GroupSession<FloxBxActivity>.Sessions {
      FloxBxActivity.sessions()
    }

    public func beginRequest(forConfiguration configuration: GroupActivityConfiguration) {
      sharingRequestSubject.send(configuration)
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
        if let groupSession {
          groupSession.leave()
          self.groupSession = nil
          self.startSharingSubject.send()
        }
      #endif
    }
  }

  public var messagePublisher: AnyPublisher<[DeltaType], Never> {
    messageSubject.eraseToAnyPublisher()
  }

  var startSharingPublisher: AnyPublisher<Void, Never> {
    startSharingSubject.eraseToAnyPublisher()
  }

  public func send(_ deltas: [DeltaType]) {
    #if canImport(GroupActivities)
      if #available(iOS 15, macOS 12, *) {
        if let groupSessionMessenger = self.groupSessionMessenger {
          Task {
            do {
              try await groupSessionMessenger.send(deltas)
            } catch {}
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
