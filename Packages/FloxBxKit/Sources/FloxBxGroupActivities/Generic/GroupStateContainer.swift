#if canImport(Combine)
  import Foundation

  #if canImport(GroupActivities)
    import GroupActivities
  #endif

  /// Contains the state of whether a GroupActivity can be started.
  class GroupStateContainer {
    let anyObserver: Any?
    @Published private(set) var isEligible = false

    init() {
      #if canImport(GroupActivities)
        if #available(macOS 12, iOS 15, *) {
          let observer = GroupStateObserver()
          self.anyObserver = observer
          observer.$isEligibleForGroupSession.assign(to: &self.$isEligible)
          self.isEligible = observer.isEligibleForGroupSession
        } else {
          anyObserver = nil
        }
      #else
        anyObserver = nil
      #endif
    }
  }
#endif
