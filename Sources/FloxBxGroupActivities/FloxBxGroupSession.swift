import Foundation

#if canImport(GroupActivities)
  import GroupActivities
#endif

public protocol ActivityGroupSessionContainer {
  #if canImport(GroupActivities)

    @available(iOS 15, macOS 12, *)
    func getValue<ActivityType: GroupActivity>() -> GroupSession<ActivityType>
  #endif
}

public struct GroupSessionContainer<IDType: Hashable> {
  let session: Any
  public let activityID: IDType
  #if canImport(GroupActivities)

    @available(iOS 15, *)
    init<ActivityType: GroupActivity & Identifiable>(groupSession: GroupSession<ActivityType>) where ActivityType.ID == IDType {
      session = groupSession
      activityID = groupSession.activity.id
    }

    @available(iOS 15, macOS 12, *)
    func getGroupSession<ActivityType: GroupActivity & Identifiable>() -> GroupSession<ActivityType> where ActivityType.ID == IDType {
      guard let session = session as? GroupSession<ActivityType> else {
        preconditionFailure()
      }

      return session
    }
  #endif
}
