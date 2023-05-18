import FelinePine
import FloxBxAuth
import Sublimation
import FloxBxUtilities
import FloxBxNetworking
import FloxBxLogging
import FloxBxModeling
import Foundation
import Combine

struct Account {
  let username: String
}

internal class ServicesObject: ObservableObject, LoggerCategorized {
  internal init(service: (any AuthorizedService)? = nil, error: Error? = nil) {
    self.service = service
    self.error = error
    
    self.$service.compactMap{$0}.map { service in
      Future{
        try await service.verifyLogin()
      }
    }.switchToLatest().map{!$0}.replaceError(with: false).receive(on: DispatchQueue.main).assign(to: &self.$requireAuthentication)
  }
  
//  internal init() {
//    //self.account = account
//    self.service = service
//    
//    self.$service.compactMap{$0}.map { service in
//      service
//    }
//  }
  
  //@Published var account: Account?
  @Published var service: (any AuthorizedService)?
  @Published var error : Error?
  @Published var requireAuthentication = false
  
  typealias LoggersType = FloxBxLogging.Loggers

  static var loggingCategory: LoggerCategory {
    .reactive
  }

  internal func begin() {
#if DEBUG
    Task {
      let service = await self.developerService(fallbackURL: Configuration.productionBaseURL)
      await MainActor.run {
        self.service = service
        
      }
    }
#else
    self.service = ServiceImpl(
      baseURL: Configuration.productionBaseURL,
      accessGroup: Configuration.accessGroup,
      serviceName: Configuration.serviceName
    )
#endif
  }
  
#if DEBUG
  private static func fetchBaseURL() async throws -> URL {
    do {
      guard let url = try await KVdb.url(
        withKey: Configuration.Sublimation.key,
        atBucket: Configuration.Sublimation.bucketName
      ) else {
        throw DeveloperServerError.noServer
      }
      return url
    } catch {
      throw DeveloperServerError.sublimationError(error)
    }
  }

  internal func developerService(fallbackURL: URL) async -> any AuthorizedService {
    let baseURL: URL
    do {
      baseURL = try await Self.fetchBaseURL()
      Self.logger.debug("Found service url: \(baseURL)")
    } catch {
      Task { @MainActor in
        self.error = error
      }
      baseURL = fallbackURL
    }
    return ServiceImpl<JSONCoder, URLSession, URLRequestBuilder, CredentialsContainer>(
      baseURL: baseURL,
      accessGroup: Configuration.accessGroup,
      serviceName: Configuration.serviceName
    )
  }
#endif
}
