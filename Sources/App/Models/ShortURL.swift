//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 25.7.24.
//

import Foundation
import struct Foundation.UUID
import Fluent

final class ShortURL: Model, @unchecked Sendable {
	static let schema = "short_urls"
	
	@ID(key: .id)
	var id: UUID?
	
	@Field(key: "initial_url")
	var initialURL: String
	
	@Field(key: "short_url")
	var shortURL: String
	
	@Timestamp(key: "created_at", on: .create)
	var createdAt: Date?
	
	@Timestamp(key: "updated_at", on: .update)
	var updatedAt: Date?
	
	
	init() {}
	
	init(id: UUID? = nil, initialURL: String, shortURL: String) {
		self.id = id
		self.initialURL = initialURL
		self.shortURL = shortURL
	}
	
	func toDTO() -> ShortUrlDTO {
		.init(
			initialURL: self.initialURL,
			shortURL: self.shortURL
		)
	}
}
