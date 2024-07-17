import Vapor
import RediStack

import CryptoKit
import Foundation
import Base58Swift
import BigInt

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


func routes(_ app: Application) throws {
    app.get { req async in
        "It works!"
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }
	app.get("short", ":link") { req -> EventLoopFuture<String> in
		let initialLink = req.parameters.get("link")!
		let cacheKey = initialLink // Use the initialLink directly as the key
		
		return req.redis.get(RedisKey(cacheKey)).flatMap { result in
			if let result = result.string {
				return req.eventLoop.future(result)
			} else {
				let generatedShortLink = generateShortLink(initialLink: initialLink)
				return req.redis.set(RedisKey(cacheKey), toJSON: generatedShortLink).flatMap {
					return req.eventLoop.future(generatedShortLink)
				}
			}
		}
	}

}
