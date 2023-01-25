
import FelinePine

#if canImport(os)
  import os
#elseif canImport(Logging)
  import Logging
#endif

public enum LoggerCategory : String, CaseIterable {
  case reactive
  // swiftlint:disable:next identifier_name
  case ui
  case userDefaults
  case watchConnectivity
  case authentication
  case networking
  case server
  case keychain
  case shareplay
}

public struct Loggers : FelinePine.Loggers {
  public static var loggers: [LoggerCategory : Logger] {
    return _loggers
  }
  
  public typealias LoggerCategory = FloxBxLogging.LoggerCategory
  
  
}
