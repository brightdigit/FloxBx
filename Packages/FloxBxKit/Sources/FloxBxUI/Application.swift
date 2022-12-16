#if canImport(SwiftUI)
  import FloxBxModels
  import os
  import SwiftUI

  public protocol Application: App {
    var appDelegate: AppDelegate { get }
  }

  extension Application {
    public var body: some Scene {
      WindowGroup {
        ContentView().environmentObject(ApplicationObject(
          mobileDevicePublisher: self.appDelegate.$mobileDevice.eraseToAnyPublisher()
        ))
      }
    }
  }

  import Combine
  import UIKit

  #if os(iOS)
    extension UIDevice {
      var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
          String(cString: ptr)
        }
        return str
      }
    }

  #elseif canImport(WatchKit)
    extension WKInterfaceDevice {
      var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
          String(cString: ptr)
        }
        return str
      }
    }
  #endif

  #if os(iOS)
    public class UIAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
      @Published var mobileDevice: CreateMobileDeviceRequestContent?

      public func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        mobileDevice = CreateMobileDeviceRequestContent(
          model: UIDevice.current.deviceName,
          operatingSystem: UIDevice.current.systemVersion,
          topic: Bundle.main.bundleIdentifier!,
          deviceToken: deviceToken
        )
      }

      public func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register logging: \(error.localizedDescription)")
      }
    }

  #elseif canImport(WatchKit)
    import WatchKit

    import Combine
    public class WKAppDelegate: NSObject, WKApplicationDelegate, ObservableObject {
      @Published var mobileDevice: CreateMobileDeviceRequestContent?

      var mobileDevicePublisher: AnyPublisher<CreateMobileDeviceRequestContent, Never> {
        mobileDevice.publisher.eraseToAnyPublisher()
      }

      public func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        mobileDevice = CreateMobileDeviceRequestContent(
          model: WKInterfaceDevice.current().deviceName,
          operatingSystem: WKInterfaceDevice.current().systemVersion,
          topic: Bundle.main.bundleIdentifier!,
          deviceToken: deviceToken
        )
      }
    }
  #endif
#endif
