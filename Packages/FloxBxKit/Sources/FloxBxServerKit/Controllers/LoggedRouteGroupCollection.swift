import FloxBxLogging
import RouteGroups
import FelinePine

protocol LoggedRouteGroupCollection : RouteGroupCollection, LoggerCategorized where LoggersType == FloxBxLogging.Loggers {
  
}

extension LoggedRouteGroupCollection {
  
  
  static var loggingCategory: LoggerCategory {
    return .networking
  }
}
