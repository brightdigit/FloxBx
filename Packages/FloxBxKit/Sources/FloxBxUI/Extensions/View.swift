#if canImport(SwiftUI)
  import FelinePine
  import FloxBxLogging
  import SwiftUI

  extension View where Self: LoggerCategorized {
    typealias LoggersType = FloxBxLogging.Loggers
    static var loggingCategory: LoggerCategory {
      .ui
    }
  }

#endif
