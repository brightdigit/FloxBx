#if canImport(Security)
  import Foundation
  import Security

  #if canImport(FoundationNetworking)
    import FoundationNetworking
  #endif

  extension KeychainContainer {
    var tokenAccountQuery: CFDictionary {
      [kSecClass as String: kSecClassGenericPassword,
       kSecAttrService as String: serviceName,
       kSecMatchLimit as String: kSecMatchLimitOne,
       kSecReturnAttributes as String: true,
       kSecReturnData as String: true,
       kSecAttrAccessGroup as String: accessGroup] as CFDictionary
    }

    var tokenUpdateQuery: CFDictionary {
      [kSecClass as String: kSecClassGenericPassword,
       kSecAttrService as String: serviceName,
       kSecAttrAccessGroup as String: accessGroup] as CFDictionary
    }

    var passwordAccountQuery: CFDictionary {
      [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: serviceName,
        kSecMatchLimit as String: kSecMatchLimitOne,
        kSecReturnAttributes as String: true,
        kSecReturnData as String: true,
        kSecAttrAccessGroup as String: accessGroup,
        kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
      ] as CFDictionary
    }

    var passwordUpdateQuery: CFDictionary {
      [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: serviceName,
        kSecAttrAccessGroup as String: accessGroup,
        kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
      ] as CFDictionary
    }

    var deleteTokenQuery: CFDictionary {
      [kSecClass as String: kSecClassGenericPassword,
       kSecAttrService as String: serviceName,
       kSecAttrAccessGroup as String: accessGroup] as CFDictionary
    }

    var deletePasswordQuery: CFDictionary {
      [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: serviceName,
        kSecAttrAccessGroup as String: accessGroup,
        kSecAttrSynchronizable as String: kSecAttrSynchronizableAny
      ] as CFDictionary
    }

    func queryForAdding(account: String, password: String) -> CFDictionary {
      let passwordData = password.data(using: String.Encoding.utf8)!

      return [kSecClass as String: kSecClassInternetPassword,
              kSecAttrAccount as String: account,
              kSecAttrServer as String: serviceName,
              kSecValueData as String: passwordData,
              kSecAttrAccessGroup as String: accessGroup,
              kSecAttrSynchronizable as String: kCFBooleanTrue!] as CFDictionary
    }

    func attributesForUpdating(account: String, password: String) -> CFDictionary {
      let passwordData = password.data(using: String.Encoding.utf8)!
      return [
        kSecAttrAccount as String: account,
        kSecValueData as String: passwordData,
        kSecAttrSynchronizable as String: kCFBooleanTrue!
      ] as CFDictionary
    }

    func queryForAdding(account: String, token: String) -> CFDictionary {
      let tokenData = token.data(using: String.Encoding.utf8)!

      return [kSecClass as String: kSecClassGenericPassword,
              kSecAttrAccount as String: account,
              kSecValueData as String: tokenData,
              kSecAttrService as String: serviceName,
              kSecAttrAccessGroup as String: accessGroup] as CFDictionary
    }

    func attributesForUpdating(account: String, token: String) -> CFDictionary {
      let tokenData = token.data(using: String.Encoding.utf8)!
      return [
        kSecAttrAccount as String: account,
        kSecValueData as String: tokenData
      ] as CFDictionary
    }
  }
#endif
