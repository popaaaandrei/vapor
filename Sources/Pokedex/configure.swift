import FluentSQLite
import Vapor

let main = DatabaseIdentifier<SQLiteDatabase>("main")

public func configure(
    _ config: inout Config,
    _ env: inout Environment,
    _ services: inout Services
) throws {
    // configure your application here
    config.prefer(InMemoryCache.self, for: Cache.self)

    // register providers
    try services.register(FluentProvider())
    try services.register(SQLiteProvider())

    // configure database
    var config = DatabaseConfig()
    let sqlite = SQLiteDatabase(storage: .file(path: "/tmp/pokedex.sqlite"))
    config.add(database: sqlite, as: main)
    services.register(config)

    // configure migrations
    var migrations = MigrationConfig()
    migrations.add(migration: Pokemon.self, database: main)
    services.register(migrations)
}
extension Request: DatabaseConnectable { }

extension HTTPStatus: FutureType {}
extension HTTPStatus: ResponseEncodable {
    public func encode(to res: inout Response, for req: Request) throws -> Future<Void> {
        let new = req.makeResponse()
        new.status = self
        res = new
        return .done
    }
}
