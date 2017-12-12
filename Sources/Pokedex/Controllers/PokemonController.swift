import FluentSQLite
import Vapor

final class PokemonController {
    /// Lists all known pokemon in our pokedex.
    func index(_ req: Request) throws -> Future<[Pokemon]> {
        return Pokemon.query(on: req).all()
    }

    /// Stores a newly discovered pokemon in our pokedex.
    func create(_ req: Request) throws -> Future<HTTPStatus> {
        let pokemon = try req.content.decode(Pokemon.self)
        return try Pokemon.query(on: req).filter(\Pokemon.name == pokemon.name).count()._map { count in
            /// check if pokemon exists already
            guard count == 0 else {
                throw Abort(.badRequest, reason: "You already caught \(pokemon.name).")
            }
        }._then {
            /// check if the pokemon is real
            return try req.verifyPokemon(named: pokemon.name)
        }._then {
            /// save the pokemon
            return pokemon.save(on: req)
        }._map {
            /// return a success indicator
            return .created
        }
    }
}

extension Request {
    /// Throws an error if the supplied pokemon does not show up on pokeapi.co.
    func verifyPokemon(named name: String) throws -> Future<Void> {
        /// create a cache
        /// we use the event loop here so that the cached data
        /// will be shared between all requests that use the same
        /// event loop. this means each pokemon name will only need
        /// to be verified by the pokeapi once per event loop.
        let cache = try eventLoop.make(Cache.self)

        /// create a consistent cache key
        let key = name.lowercased()
        return cache.get(Bool.self, forKey: key)._then { result in
            if let exists = result, exists {
                /// this pokemon name is in the cache,
                /// simply return .done
                return .done
            }

            /// create the client to query the pokeapi
            /// we don't use the event loop here since there
            /// is no benefit to sharing a client between multiple requests.
            let client = try self.make(Client.self)

            /// no id for this pokemon name was cached, we must
            /// fetch from the api
            return client.fetchPokemon(named: name)._then { res in
                switch res.status.code {
                case 400...:
                    return cache.set(false, forKey: key)._map {
                        throw Abort(.badRequest, reason: "Invalid Pokemon name: \(name).")
                    }
                default: return cache.set(true, forKey: key)
                }
            }
        }
    }
}

extension Client {
    /// fetches a pokemen with the supplied name from the pokeapi
    func fetchPokemon(named name: String) -> Future<Response> {
        let uri = URI(stringLiteral: "http://pokeapi.co/api/v2/pokemon/\(name)")
        return get(uri)
    }
}
