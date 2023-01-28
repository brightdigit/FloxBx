import FelinePine

#if canImport(os)
  import os
#elseif canImport(Logging)
  import Logging
#endif

public struct Loggers: FelinePine.Loggers {
  public static var loggers: [LoggerCategory: Logger] {
    _loggers
  }

  public typealias LoggerCategory = FloxBxLogging.LoggerCategory
}
