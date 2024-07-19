import Vapor
import Leaf

struct PagesController : RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(use: index)
    }

    func index(_ req: Request) -> EventLoopFuture<View> {
        return req.view.render("index")
    }

}