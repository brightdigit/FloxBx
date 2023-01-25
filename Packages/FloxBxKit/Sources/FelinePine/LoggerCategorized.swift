//
// LoggerCategorized.swift
// Copyright (c) 2022 BrightDigit.
//

import Foundation
#if canImport(os)
  import os
#else
  import Logging
#endif

public protocol LoggerCategorized: Loggable {
  associatedtype LoggersType : Loggers
  static var loggingCategory: LoggersType.LoggerCategory {
    get
  }
}

public extension LoggerCategorized {
  static var logger: Logger {
    LoggersType.forCategory(loggingCategory)
  }
}
