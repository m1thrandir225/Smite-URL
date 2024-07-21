import Vapor
import Leaf
import RediStack

//Pages Controller

/**
* GET / -> Homepage
* GET /:shortURL -> Redirect to a viable short url
**/

struct PagesController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
        routes.group(":shortURL") { withParam in 
            withParam.get(use: single)
        }
    }

    func index(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("index")
    }
    func single(_ req: Request) async throws -> Response {
        let urlParameter = req.parameters.get("shortURL")!
		
		let key = RedisKey(urlParameter)
		
		let value = try await req.redis.get(key, asJSON: ShortURL.self)
		
		if let result = value {
			return req.redirect(to:  result.initialURL, redirectType: .permanent)
		}
		throw Abort(.notFound)
    }
}