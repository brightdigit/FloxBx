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

  #if os(iOS)
    import UIKit
    extension UIDevice: Device {}
    extension UIApplication: AppInterface {
      public static var sharedInterface: AppInterface {
        UIApplication.shared
      }

      public static var currentDevice: Device {
        UIDevice.current
      }
    }

    public typealias ApplicationDelegateAdaptor = UIApplicationDelegateAdaptor
    public typealias AppInterfaceObject = UIApplication

  #elseif os(watchOS)
    import WatchKit
    extension WKInterfaceDevice: Device {}
    extension WKApplication: AppInterface {
      public static var currentDevice: Device {
        WKInterfaceDevice.current()
      }

      public static var sharedInterface: AppInterface {
        WKApplication.shared()
      }
    }

    public typealias ApplicationDelegateAdaptor = WKApplicationDelegateAdaptor
    public typealias AppInterfaceObject = WKApplication
#elseif os(macOS)
import AppKit
extension NSApplication : AppInterface {
  public static var sharedInterface: AppInterface {
    return NSApplication.shared
  }
  
  public static var currentDevice: Device {
    fatalError()
  }
}


public typealias ApplicationDelegateAdaptor = NSApplicationDelegateAdaptor
public typealias AppInterfaceObject = NSApplication
  #endif

  public protocol Device {
    var systemVersion: String { get }
  }

  extension Device {
    public var name: String {
      var systemInfo = utsname()
      uname(&systemInfo)
      let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
        String(cString: ptr)
      }
      return str
    }
  }

  public protocol AppInterface {
    static var sharedInterface: AppInterface { get }
    static var currentDevice: Device { get }
    func registerForRemoteNotifications() async
    func unregisterForRemoteNotifications() async
  }

  public class AppDelegate: NSObject, ObservableObject {
    @Published var mobileDevice: CreateMobileDeviceRequestContent?
    public func didRegisterForRemoteNotifications<AppInterfaceType: AppInterface>(from _: AppInterfaceType?, withDeviceToken deviceToken: Data) {
      mobileDevice = CreateMobileDeviceRequestContent(
        model: AppInterfaceType.currentDevice.name,
        operatingSystem: AppInterfaceType.currentDevice.systemVersion,
        topic: Bundle.main.bundleIdentifier!,
        deviceToken: deviceToken
      )
    }
  }

  #if os(iOS)
    extension AppDelegate: UIApplicationDelegate {
      public func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        didRegisterForRemoteNotifications(from: app, withDeviceToken: deviceToken)
      }

      public func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register logging: \(error.localizedDescription)")
      }
    }

  #elseif canImport(WatchKit)
    import Combine
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
#endif
