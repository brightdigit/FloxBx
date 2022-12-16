import APNS
import FloxBxDatabase
import enum FloxBxModels.Configuration
import protocol FloxBxModels.Notifiable
import struct FloxBxModels.PayloadNotification
import struct FloxBxModels.TagPayload
import FluentPostgresDriver
import SublimationVapor
import Vapor

public struct MissingConfigurationError: Error {
  let key: String
}

extension Notifiable {
  var alertNotification: APNSAlertNotification<PayloadType> {
    .init(
      alert: .init(title: .raw(self.title)),
      expiration: .immediately,
      priority: .immediately,
      topic: self.topic,
      payload: self.payload
    )
  }
}

extension Application {
  public func sendNotification(_ notification: PayloadNotification<TagPayload>) async throws {
    try await self.apns.client.sendAlertNotification(
      .init(
        alert: .init(title: .raw(notification.title)),
        expiration: .immediately,
        priority: .immediately,
        topic: notification.topic,
        payload: notification.payload
      ),
      deviceToken: notification.deviceToken.map { data in String(format: "%02.2hhx", data) }.joined(),
      deadline: .distantFuture
    )
  }
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

    guard let keyIdentifier = Environment.get("APNS_KEY_IDENTIFIER") else {
      throw MissingConfigurationError(key: "APNS_KEY_IDENTIFIER")
    }

    guard let teamIdentifier = Environment.get("APNS_TEAM_IDENTIFIER") else {
      throw MissingConfigurationError(key: "APNS_TEAM_IDENTIFIER")
    }

    try app.apns.containers.use(
      .init(
        authenticationMethod: .jwt(
          // 3
          privateKey: .init(pemRepresentation: appleECP8PrivateKey),
          keyIdentifier: keyIdentifier,
          teamIdentifier: teamIdentifier
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

    app.databases.middleware.configure(notify: app.sendNotification(_:))
    // app.databases.middleware.configure(notify: app.sendNotification)
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
