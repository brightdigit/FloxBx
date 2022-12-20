#if os(watchOS) && canImport(SwiftUI)
  import SwiftUI
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
#endif
