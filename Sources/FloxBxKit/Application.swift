//
//  FloxBxApp.swift
//  Shared
//
//  Created by Leo Dion on 5/10/21.
//


//import SentryCocoa
import SentryVanilla

public class Sentry {
  public static func start () {
    try? SentryVanilla.Sentry.start { options in
      options.dsn = "https://d2a8d5241ccf44bba597074b56eb692d@o919385.ingest.sentry.io/5868822"
      
      //options.debug = true // Enabled debug when first installing is always helpful
    }
    SentryVanilla.Sentry.capture(event: .init(message: "Hello World", tags: nil), configureScope: nil)
//    
//    SentryCocoa.SentrySDK.start { options in
//      options.dsn
//      options.de
//    }
  }
}

#if canImport(SwiftUI)
import SwiftUI
public protocol Application: App {
  
}

public extension Application {
  var body: some Scene {
      WindowGroup {
        ContentView().environmentObject(ApplicationObject())
      }
  }
}
#endif
