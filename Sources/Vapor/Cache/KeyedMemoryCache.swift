import Async
import Dispatch

/// Stores key-value pair in a dictionary.
///
/// This is not thread safe. Create one of these per event loop.
///
///     let cache = try req.eventLoop.make(Cache.self)
///
/// See `SharedInMemoryCache` for a threadsafe (less performant) option
public final class InMemoryCache: Cache {
    /// The underlying storage of this cache
    private var storage = [String: Any]()

    /// The cache uses the provided queue for synchronous thread-safe access
    public init() {}

    /// Retreived a value from the cache
    public func get<D>(_ type: D.Type, forKey key: String) -> Future<D?> where D: Decodable {
        return Future(self.storage[key] as? D)
    }

    /// Sets a new value in the cache
    public func set<E>(_ entity: E, forKey key: String) -> Future<Void> where E: Encodable {
        self.storage[key] = entity
        return .done
    }
}


/// Stores key-value pair in a dictionary thread-safely
///
/// Share this between event loops.
///
///     let cache = try app.make(Cache.self)
///     let controller = MyController(cache: cache)
///
/// See `InMemoryCache` for a non-threadsafe (more performant) option
public final class SharedInMemoryCache: Cache {
    /// The underlying storage of this cache
    private var storage = [String: Any]()
    
    /// The cache uses this queue for synchronous thread-safe access
    private let queue: DispatchQueue
    
    /// The cache uses the provided queue for synchronous thread-safe access
    public init() {
        self.queue = DispatchQueue(label: "codes.vapor.cache.inMemory")
    }
    
    /// Retreived a value from the cache
    public func get<D>(_ type: D.Type, forKey key: String) -> Future<D?> where D: Decodable {
        let promise = Promise(D?.self)
        queue.async {
            promise.complete(self.storage[key] as? D)
        }
        return promise.future
    }
    
    /// Sets a new value in the cache
    public func set<E>(_ entity: E, forKey key: String) -> Future<Void> where E: Encodable {
        let promise = Promise(Void.self)
        queue.async {
            self.storage[key] = entity
            promise.complete()
        }
        return promise.future
    }
}
