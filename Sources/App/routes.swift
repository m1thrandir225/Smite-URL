import Vapor
import RediStack

import Foundation
import BigInt
import NIO

extension Digest {
	var bytes: [UInt8] { Array(makeIterator())}
	var data: Data { Data(bytes)}
	
	var hexStr: String {
		bytes.map {
			String(format: "%02X", $0)
		}.joined()
	}
}

func sha256f(input: String) -> Data {
	let dataFromString = input.data(using: .utf8)!
	let digest = SHA256.hash(data: dataFromString)
	
	return digest.data
}


func base64URLEncoded(_ input: Data) -> String {
	let base64String = input.base64EncodedString()
	
	let urlSafeBase64String = base64String
		.replacingOccurrences(of: "+", with: "-")
		.replacingOccurrences(of: "/", with: "-")
		.replacingOccurrences(of: "=", with: "")
	return urlSafeBase64String
}


func generateShortLink(initialLink: String) -> String {
	let combinedString = initialLink
	let urlHashBytes = sha256f(input: combinedString)
	let generatedNumber = BigUInt(urlHashBytes).description
	
	let generatedBytes = Data(generatedNumber.utf8)
	let finalString = base64URLEncoded(generatedBytes)
	return  String(finalString.prefix(8))
}

//func getFromCache(key: String) -> String {
//
//}

private func expireRedisKey(_ key: RedisKey, redis: Vapor.Request.Redis) {
	let expireDuration = TimeAmount.hours(6)
	_ = redis.expire(key, after: expireDuration)
}

func routes(_ app: Application) throws {
	app.post("short") { req async throws -> ShortURL in
		do {
			let initialLink = try req.content.decode(CreateShortURLRequest.self)
			
			let generatedShortLink = generateShortLink(initialLink: initialLink.url)

			let cacheKey = generatedShortLink // Use the initialLink directly as the key
			
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
