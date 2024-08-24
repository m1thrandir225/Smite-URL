//
//  File.swift
//  
//
//  Created by Sebastijan Zindl on 25.7.24.
//
@testable import App
import XCTVapor
final class ShortURlTests : XCTestCase {
	var app: Application!
	
	override func setUp() async throws {
		self.app = try await Application.make(.testing)
		try await configure(app)
	}
	
	override func tearDown() async throws {
		try await self.app.asyncShutdown()
		self.app = nil
	}
	
	func testCreate() {
		let shortURL = ShortURL(initialURL: "", shortURL: "")
	}
}
