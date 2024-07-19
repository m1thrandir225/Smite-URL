import Vapor
import RediStack

import Foundation
import NIO


private func expireRedisKey(_ key: RedisKey, redis: Vapor.Request.Redis) {
	let expireDuration = TimeAmount.hours(6)
	_ = redis.expire(key, after: expireDuration)
}

func routes(_ app: Application) throws {
	try app.register(collection: PagesController())
	
	app.post("short") { req async throws -> ShortURL in
		do {
			let initialLink = try req.content.decode(CreateShortURLRequest.self)
			
			let generatedShortLink = generateShortURL(initialLink: initialLink.url)

			let cacheKey = generatedShortLink
			
			let cachedValue = try await req.redis.get(RedisKey(cacheKey), asJSON: ShortURL.self)

			if let cachedValue = cachedValue {
				return cachedValue
			} else {
				
				let shortURLObject = ShortURL(initialURL: initialLink.url, shortURL: generatedShortLink)
				
				req.redis.set(RedisKey(cacheKey), toJSON: shortURLObject).whenComplete { result in
					switch result {
					case .success:
						expireRedisKey(RedisKey(cacheKey), redis: req.redis)
					case .failure(let error):
						print("The request was not cached. Reason: \(error)")
					}
				}
				
				return shortURLObject
			}
		} catch {
			throw Abort(.internalServerError)
		}
	}
	
	app.get("url", ":shortURL") { req async throws -> Response in
		let urlParameter = req.parameters.get("shortURL")!
		
		let key = RedisKey(urlParameter)
		
		let value = try await req.redis.get(key, asJSON: ShortURL.self)
		
		if let result = value {
			return req.redirect(to:  result.initialURL, redirectType: .permanent)
		}
		throw Abort(.notFound)
	}
}
