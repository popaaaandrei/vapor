import FluentSQLite
import Vapor

final class Routes: RouteCollection {
    let app: Application

    init(app: Application) {
        self.app = app
    }

    func boot(router: Router) throws {
        let controller = PokemonController()
        router.get("pokemon", use: controller.index)
        router.post("pokemon", use: controller.create)
    }
}
