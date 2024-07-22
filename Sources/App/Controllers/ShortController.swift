import Vapor
import RediStack

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

	func single(_ req: Request) async throws -> ShortURL {
		let urlParameter = req.parameters.get("shortURL")!
		
		let key = RedisKey(urlParameter)
		
		let value = try await req.redis.get(key, asJSON: ShortURL.self)
		
		if let result = value {
			return result
		}
		throw Abort(.notFound)
	}


    func create(_ req: Request) async throws -> ShortURL { 
		do {
			let initialLink = try req.content.decode(CreateShortURLRequest.self)

			print(initialLink);
			
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
        } catch (let error){
            throw Abort(.internalServerError, reason: "Reson: \(error)")
        }
    }
}
