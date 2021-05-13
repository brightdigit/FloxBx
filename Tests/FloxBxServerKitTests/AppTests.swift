@testable import FloxBxServerKit
import XCTVapor

final class AppTests: XCTestCase {
    func testHelloWorld() throws {
      let app = Application(.testing)
      try Server.configure(app)
      
      defer { app.shutdown() }
      
      
      try app.test(.POST, "users") { request in
        //CreateUserRequestContent(emailAddress: UUID().uuidString, password: UU)
      } afterResponse: { response in
        
      }

    }
}
