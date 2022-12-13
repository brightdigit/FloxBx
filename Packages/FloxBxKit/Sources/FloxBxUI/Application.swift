#if canImport(SwiftUI)
  import FloxBxModels
  import SwiftUI
  import os

  public protocol Application: App {
    #if os(iOS)
      var appDelegate: UIAppDelegate { get }
    #elseif canImport(WatchKit)
      var appDelegate: WKAppDelegate { get }
    #endif
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

  
    import UIKit
import Combine

#if os(iOS)
extension UIDevice {
  var deviceName : String {
     get {
       var systemInfo = utsname()
       uname(&systemInfo)
       let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
         return String(cString: ptr)
       }
       return str
     }
   }
}
#elseif canImport(WatchKit)
extension WKInterfaceDevice {
  var deviceName : String {
     get {
       var systemInfo = utsname()
       uname(&systemInfo)
       let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
         return String(cString: ptr)
       }
       return str
     }
   }
}
#endif

#if os(iOS)
    public class UIAppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
      @Published var mobileDevice: CreateMobileDeviceRequestContent?
      
      public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.mobileDevice = CreateMobileDeviceRequestContent(
          model: UIDevice.current.deviceName,
          operatingSystem: UIDevice.current.systemVersion,
          topic: Bundle.main.bundleIdentifier!,
          deviceToken: deviceToken
        )
      }
      public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("Unable to register logging: \(error.localizedDescription)")
      }
    }

#elseif canImport(WatchKit)
    import WatchKit

import Combine
    public class WKAppDelegate: NSObject, WKApplicationDelegate, ObservableObject {
      @Published var mobileDevice: CreateMobileDeviceRequestContent?
      
      
      var mobileDevicePublisher : AnyPublisher<CreateMobileDeviceRequestContent, Never> {
        self.mobileDevice.publisher.eraseToAnyPublisher()
      }
      
      public func didRegisterForRemoteNotifications(withDeviceToken deviceToken: Data) {
        self.mobileDevice = CreateMobileDeviceRequestContent(
          model: WKInterfaceDevice.current().deviceName,
          operatingSystem: WKInterfaceDevice.current().systemVersion,
          topic: Bundle.main.bundleIdentifier!,
          deviceToken: deviceToken
        )
      }
      
    }
#endif
#endif
