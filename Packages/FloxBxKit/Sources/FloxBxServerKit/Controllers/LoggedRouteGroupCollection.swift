import FelinePine
import FloxBxLogging
import RouteGroups

@available(*, deprecated, renamed: "RouteGroupCollection")
protocol LoggedRouteGroupCollection: RouteGroupCollection, LoggerCategorized
  where LoggersType == FloxBxLogging.Loggers {}

extension LoggedRouteGroupCollection {
  static var loggingCategory: LoggerCategory {
    .networking
  }
}

extension RouteGroupCollection where Self: LoggerCategorized {
  typealias LoggersType = FloxBxLogging.Loggers
  static var loggingCategory: LoggerCategory {
    .ui
  }
}