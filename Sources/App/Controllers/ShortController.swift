import Vapor
import RediStack
import Fluent
import FluentKit

//API Controller

/**
 * POST /api/urls -> Create a short URL
 * GET /api/urls/:shortURL -> get a short url object
 **/

struct ShortController: RouteCollection {
	func boot(routes: RoutesBuilder) throws {
		let shortenedURLS = routes.grouped("api", "urls")
		shortenedURLS.post(use: create)
		
		shortenedURLS.group(":shortURL") { withParam in
			withParam.get(use: single)
		}
	}
	
	@Sendable
	func single(_ req: Request) async throws -> ShortUrlDTO {
		let urlParameter = req.parameters.get("shortURL")!
		
		let key = RedisKey(urlParameter)
		
		let value = try await req.redis.get(key, asJSON: ShortURL.self)
		
		if let result = value {
			return result.toDTO()
		}
		
		let valueFromDB = try await ShortURL.query(on: req.db).filter(\.$initialURL == urlParameter).first()
		
		if let result = valueFromDB {
			return result.toDTO()
		}
		
		throw Abort(.notFound)
	}
	
	@Sendable
	func create(_ req: Request) async throws -> ShortUrlDTO {
		do {
			let initialLink = try req.content.decode(CreateShortURLRequest.self)
			
			let generatedShortLink = generateShortURL(initialLink: initialLink.url)
			
			let cacheKey = generatedShortLink
			
			let cachedValue = try await req.redis.get(RedisKey(cacheKey), asJSON: ShortURL.self)
			
			if let cachedValue = cachedValue {
				return cachedValue.toDTO()
			}
			
			let valueInDB = try await ShortURL.query(on: req.db).filter(\.$initialURL == initialLink.url).first()
			
			if let cachedValue = valueInDB {
				return cachedValue.toDTO()
			}
			
			let shortURL = ShortURL(initialURL: initialLink.url, shortURL: generatedShortLink)
			
			req.redis.set(RedisKey(cacheKey), toJSON: shortURL).whenComplete { result in
				switch result {
				case .success:
					expireRedisKey(RedisKey(cacheKey), redis: req.redis)
				case .failure(let error):
					print("The request was not cached. Reason: \(error)")
				}
			}
			
			try await shortURL.create(on: req.db)
			
			return shortURL.toDTO()
			
		} catch (let error){
			throw Abort(.internalServerError, reason: "Reson: \(error)")
		}
	}
}
