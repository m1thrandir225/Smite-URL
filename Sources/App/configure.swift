import Vapor
import Redis
import Leaf
import Fluent
import FluentPostgresDriver

// configures your application
public func configure(_ app: Application) async throws {

	/**
	 *
	 * Redis Configuration
	 *
	 */
	let redisHostname = Environment.get("REDIS_HOST") ?? "localhost"
	let redisPort = Environment.get("REDIS_PORT") ?? "6379"
	app.redis.configuration = try RedisConfiguration(
		hostname: redisHostname,
		port: Int(redisPort) ?? 6379
	)


	/**
	 *
	 *	Postgres Configuration
	 *
	 */

	//TODO: add environment variables
	let dbHostname = Environment.get("DATABASE_HOST") ?? ""
	let dbName = Environment.get("DATABASE_NAME") ?? ""
	let dbUsername = Environment.get("DATABASE_USERNAME") ?? ""
	let dbPassword = Environment.get("DATABASE_PASSWORD") ?? ""
	app.databases.use(
		.postgres(
			configuration: .init(
				hostname: dbHostname,
				username: dbUsername,
				password: dbPassword,
				database: dbName,
				tls: .disable
			)
		),
		as: .psql
	)
	/**
	 *
	 * Migrations
	 *
	 */
	app.migrations.add(InitialMigration())


	/**
	 *
	 * File Middleware
	 *
	 */
	app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

	/**
	 *
	 * Leaf Templating
	 *
	 */
	app.views.use(.leaf)

	/**
	 *
	 * Register Routes
	 *
	 */
	try routes(app)
}
