import Vapor
import Redis
import Leaf

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // register routes
	let redisHostname = Environment.get("REDIS_HOST") ?? "cache"
	let redisPort = Environment.get("REDIS_PORT") ?? "6379"
	app.redis.configuration = try RedisConfiguration(
		hostname: redisHostname,
		port: Int(redisPort) ?? 6379
	)

	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	app.views.use(.leaf)

    try routes(app)
}
