#if canImport(WatchKit)

  import WatchKit
  extension AppDelegate: WKApplicationDelegate {
    public func didRegisterForRemoteNotificaions(withDeviceToken deviceToken: Data) {
      didRegisterForRemoteNotifications(from: WKApplication.shared(), withDeviceToken: deviceToken)
    }

    public func didFailToRegisterForRemoteNotificationsWithError(_ error: Error) {
      debugPrint("Unable to register logging: \(error.localizedDescription)")
    }
  }
#endif
