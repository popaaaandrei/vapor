import Async

/// A key-value cache
public protocol Cache {
    /// Gets the value as type `D` deserialized from the value associated with the `key`
    ///
    /// Returns an empty future that triggers on successful storage
    func get<D: Decodable>(_ type: D.Type, forKey key: String) -> Future<D?>
    
    /// Sets the value to `entity` stored associated with the `key`
    ///
    /// Returns an empty future that triggers on successful storage
    func set<E: Encodable>(_ entity: E?, forKey key: String) -> Future<Void>
}

extension Cache {
    /// Sets `nil` at the associated key.
    public func remove(_ key: String) -> Future<Void> {
        return set(nil as String?, forKey: key)
    }
}
