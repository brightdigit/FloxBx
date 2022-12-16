import APNS
import FloxBxDatabase
import enum FloxBxModels.Configuration
import FluentPostgresDriver
import SublimationVapor
import Vapor

public struct MissingConfigurationError: Error {
  let key: String
}

public struct Server {
  private let env: Environment

  public init(env: Environment) {
    self.env = env
  }

  public init() throws {
    var env = try Environment.detect()
    try LoggingSystem.bootstrap(from: &env)
    self.init(env: env)
  }

  static func apns(_ app: Application) throws {
    guard let appleECP8PrivateKey = Environment.get("APNS_PRIVATE_KEY") else {
      throw MissingConfigurationError(key: "APNS_PRIVATE_KEY")
    }

    try app.apns.containers.use(
      .init(
        authenticationMethod: .jwt(
          // 3
          privateKey: .init(pemRepresentation: appleECP8PrivateKey),
          keyIdentifier: "MZDGM87R59",
          teamIdentifier: "VS77J6GKJ8"
        ),
        // 5
        environment: .sandbox
      ),
      eventLoopGroupProvider: .createNew,
      responseDecoder: .init(),
      requestEncoder: .init(),
      backgroundActivityLogger: app.logger, as: .default
    )
  }

  fileprivate static func databases(_ app: Application) {
    app.databases.use(.postgres(
      hostname: Environment.get("DATABASE_HOST") ?? "localhost",
      username: Environment.get("DATABASE_USERNAME") ?? "floxbx", password: ""
    ), as: .psql)

    app.databases.middleware.configure()
  }

  fileprivate static func sublimation(_ app: Application) {
    if !app.environment.isRelease {
      app.lifecycle.use(
        SublimationLifecycleHandler(
          ngrokPath:
          Environment.get("NGROK_PATH") ?? "/opt/homebrew/bin/ngrok",
          bucketName:
          Environment.get("SUBLIMATION_BUCKET") ?? Configuration.Sublimation.bucketName,
          key:
          Environment.get("SUBLIMATION_KEY") ?? Configuration.Sublimation.key
        )
      )
    }
  }

  public static func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    sublimation(app)
    try apns(app)
    databases(app)
    app.migrations.configure()
    try app.routes.register(collection: Routes())
    try app.autoMigrate().wait()

//    Task {
//      app.apns.client.sendAlertNotification(<#T##notification: APNSAlertNotification<Encodable>##APNSAlertNotification<Encodable>#>, deviceToken: <#T##String#>, deadline: <#T##NIODeadline#>)
//    }
  }

  @discardableResult
  public func start() throws -> Application {
    let app = Application(env)
    defer { app.shutdown() }
    try Server.configure(app)
    try app.run()
    return app
  }
}
