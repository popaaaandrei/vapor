import Pokedex
import Vapor

var config = Config.default()
var env = Environment.detect()
var services = Services.default()

try Pokedex.configure(&config, &env, &services)

let app = try Application(
    config: config,
    environment: env,
    services: services
)

final class User: Decodable {
    var name: String
    var age: Double
    var luckyNumber: Int
    var isAdmin: Bool
    var user: User?
    var friend: User?

    init() {
        self.name = ""
        self.age = 21
        self.luckyNumber = 5
        self.isAdmin = true
    }
}

let mapper = KeyStringMapper()
let path = mapper.codingPath(forKey: \User.user?.friend?.user?.name, on: User.self)
print(path.map { $0.stringValue }.joined(separator: ".")) // user.user.user.user.name

try Pokedex.boot(app)

try app.run()
