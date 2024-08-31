import Vapor
import RediStack

import Foundation
import NIO


func routes(_ app: Application) throws {
	try app.register(collection: PagesController())
	try app.register(collection: ShortController())
}
