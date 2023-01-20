#if os(watchOS) && canImport(SwiftUI)
  import SwiftUI
  import WatchKit

  public typealias ApplicationDelegateAdaptor = WKDelegateAdaptor
  public typealias AppInterfaceObject = WKAppPolyfill

  #if swift(>=5.7)
    public typealias WKDelegateAdaptor = WKApplicationDelegateAdaptor
    public typealias WKDelegate = WKApplicationDelegate
  #else
    public typealias WKDelegateAdaptor = WKExtensionDelegateAdaptor
    public typealias WKDelegate = WKExtensionDelegate
  #endif

  #if swift(>=5.7)
    public typealias WKAppPolyfill = WKApplication
  #else
    public typealias WKAppPolyfill = WKExtension
  #endif

  extension WKAppPolyfill: AppInterface {
    public static var currentDevice: Device {
      WKInterfaceDevice.current()
    }

    public static var sharedInterface: AppInterface {
      WKAppPolyfill.shared()
    }
  }

#endif
