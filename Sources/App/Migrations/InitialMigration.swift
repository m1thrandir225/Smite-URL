//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 25.7.24.
//

import Foundation
import Fluent


struct InitialMigration: AsyncMigration {
	func prepare(on database: any Database) async throws {
		try await database.schema("short_urls")
			.id()
			.field("initial_url", .string, .required)
			.field("short_url", .string, .required)
			.field("created_at", .date)
			.field("updated_at", .date)
			.unique(on: "initial_url", "short_url")
			.create()
			
	}
	
	func revert(on database: any Database) async throws {
		try await database.schema("short_urls").delete()
	}
}
