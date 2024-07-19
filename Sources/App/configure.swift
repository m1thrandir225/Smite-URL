import Vapor
import Redis
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // register routes
	app.redis.configuration = try RedisConfiguration(hostname: "localhost")
	
	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	app.views.use(.leaf)
	
	try await tailwind(app)
    try routes(app)
}
