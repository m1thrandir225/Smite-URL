//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 18.7.24.
//

import Vapor


struct ShortUrlDTO: Content {
	let initialURL: String
	let shortURL: String
	
	func toModel() -> ShortURL {
		.init(
			initialURL: self.initialURL,
			shortURL: self.shortURL
		)
	}
}
