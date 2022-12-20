#if canImport(Darwin)
  import Darwin

  public protocol Device {
    var systemVersion: String { get }
  }

  extension Device {
    public var name: String {
      var systemInfo = utsname()
      uname(&systemInfo)
      let str = withUnsafePointer(to: &systemInfo.machine.0) { ptr in
        String(cString: ptr)
      }
      return str
    }
  }
#endif
