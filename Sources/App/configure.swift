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
	let redisHostname = Environment.get("REDIS_HOST") ?? ""
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
	app.databases.use(
		.postgres(
			configuration: .init(
				hostname: "localhost",
				username: "vapor_username",
				password: "vapor_password",
				database: "vapor_database",
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
