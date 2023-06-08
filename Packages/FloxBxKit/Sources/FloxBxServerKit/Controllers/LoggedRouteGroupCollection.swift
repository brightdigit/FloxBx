import FelinePine
import FloxBxLogging
import RouteGroups

extension RouteGroupCollection {
  internal static var loggingCategory: LoggerCategory {
    .networking
  }
}

extension RouteGroupCollection where Self: LoggerCategorized {
  internal typealias LoggersType = FloxBxLogging.Loggers
  internal static var loggingCategory: LoggerCategory {
    .ui
  }
}
