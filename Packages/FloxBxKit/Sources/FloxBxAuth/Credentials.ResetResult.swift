import Foundation

extension Credentials {
  public struct ResetResult: OptionSet {
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    public var rawValue: Int

    public typealias RawValue = Int

    public static let password: Self = .init(rawValue: 1)
    public static let token: Self = .init(rawValue: 2)
    public static let all: Self = [.password, .token]
  }
}

extension Credentials.ResetResult {
  public init(didDeletePassword: Bool, didDeleteToken: Bool) {
    let didDeleteToken: Self? = didDeleteToken ? .token : nil
    let didDeletePassword: Self? = didDeletePassword ? .password : nil
    self = .init([didDeleteToken, didDeletePassword].compactMap { $0 })
  }
}
