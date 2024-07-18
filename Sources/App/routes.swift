import Vapor
import RediStack

import CryptoKit
import Foundation
import Base58Swift
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

func base58Encoded(bytes: [UInt8]) -> String {
	let encodedString = Base58.base58Encode(bytes)
	
	return encodedString
}


func generateShortLink(initialLink: String) -> String {
	let combinedString = initialLink
	let urlHashBytes = sha256f(input: combinedString)
	let generatedNumber = BigUInt(urlHashBytes).description
	
	let generatedBytes = [UInt8](Data(generatedNumber.utf8))
	let finalString = base58Encoded(bytes: generatedBytes)
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
	
	app.get("url", ":shortURL") { req async throws -> ShortURL in
		let urlParameter = req.parameters.get("shortURL")!
		
		let key = RedisKey(urlParameter)
		
		let value = try await req.redis.get(key, asJSON: ShortURL.self)
		
		if let result = value {
			return result
		}
		throw Abort(.notFound)
	}
}
