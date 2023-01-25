//
// Logger.swift
// Copyright (c) 2022 BrightDigit.
//

import Foundation
#if canImport(os)
  import os
#else
  import Logging
#endif



public protocol Loggers {
  associatedtype LoggerCategory : CaseIterable & Hashable & RawRepresentable where LoggerCategory.RawValue == String
  static var loggers: [LoggerCategory: Logger] { get }

}

public extension Loggers {
  static var _loggers : [LoggerCategory: Logger]  {
    .init(
        uniqueKeysWithValues: LoggerCategory.allCases.map {
          ($0, Logger(category: $0))
        }
        )
  }
  static func forCategory(_ category: LoggerCategory) -> Logger {
    guard let logger = Self.loggers[category] else {
      preconditionFailure("missing logger")
    }
    return logger
  }
}

extension Logger {
  // swiftlint:disable:next force_unwrapping
  static let subsystem: String = Bundle.main.bundleIdentifier!


  init<LoggerCategory : RawRepresentable>(category: LoggerCategory)  where LoggerCategory.RawValue == String{
    #if canImport(os)
      self.init(subsystem: Self.subsystem, category: category.rawValue)
    #else
      self.init(label: Self.subsystem)
      self[metadataKey: "category"] = "\(category)"
    #endif
  }
}
