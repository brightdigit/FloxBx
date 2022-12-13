//
//  FloxBxApp.swift
//  Shared
//
//  Created by Leo Dion on 5/10/21.
//

import SwiftUI
import FloxBxUI

@main
struct FloxBxApp: Application {
#if os(iOS)
   @UIApplicationDelegateAdaptor var appDelegate: UIAppDelegate
#elseif canImport(WatchKit)
  @WKApplicationDelegateAdaptor var appDelegate: WKAppDelegate
#endif
}
