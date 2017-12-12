import FluentSQLite
import Foundation
import Vapor

final class Pokemon: Content, Migration, Model, Parameter, Timestampable {
    typealias Database = SQLiteDatabase

    static let keyStringMap: KeyStringMap = [
        key(\.id): "id",
        key(\.name): "name",
        key(\.createdAt): "createdAt",
        key(\.updatedAt): "updatedAt",
    ]
    static let idKey = \Pokemon.id
    static let database = main

    var id: UUID?
    let name: String
    var createdAt: Date?
    var updatedAt: Date?

    init(id: UUID? = nil, name: String) {
        self.id = id
        self.name = name
    }

    static func prepare(on connection: SQLiteConnection) -> Future<Void> {
        return connection.create(self) { pokemon in
            try pokemon.field(for: \.id)
            try pokemon.field(for: \.name)
            try pokemon.field(for: \.createdAt)
            try pokemon.field(for: \.updatedAt)
        }
    }

    static func revert(on connection: SQLiteConnection) -> Future<Void> {
        return connection.delete(self)
    }
}
