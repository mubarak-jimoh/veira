import Foundation
import VeiraCore

/// Typed key-value storage contract.
public protocol KeyValueStore: Sendable {
    func data(forKey key: String) throws -> Data?
    func setData(_ data: Data?, forKey key: String) throws
    func removeValue(forKey key: String) throws
    func bool(forKey key: String) -> Bool
    func setBool(_ value: Bool, forKey key: String)
    func string(forKey key: String) -> String?
    func setString(_ value: String?, forKey key: String)
}

/// UserDefaults-backed store for non-sensitive preferences.
public final class UserDefaultsKeyValueStore: KeyValueStore, @unchecked Sendable {
    private let defaults: UserDefaults
    private let suiteName: String?

    public init(suiteName: String? = nil) {
        self.suiteName = suiteName
        if let suiteName, let suite = UserDefaults(suiteName: suiteName) {
            self.defaults = suite
        } else {
            self.defaults = .standard
        }
    }

    public func data(forKey key: String) throws -> Data? {
        defaults.data(forKey: key)
    }

    public func setData(_ data: Data?, forKey key: String) throws {
        defaults.set(data, forKey: key)
    }

    public func removeValue(forKey key: String) throws {
        defaults.removeObject(forKey: key)
    }

    public func bool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }

    public func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    public func string(forKey key: String) -> String? {
        defaults.string(forKey: key)
    }

    public func setString(_ value: String?, forKey key: String) {
        defaults.set(value, forKey: key)
    }
}

/// In-memory store for tests.
public final class InMemoryKeyValueStore: KeyValueStore, @unchecked Sendable {
    private let lock = NSLock()
    private var storage: [String: Data] = [:]
    private var bools: [String: Bool] = [:]
    private var strings: [String: String] = [:]

    public init() {}

    public func data(forKey key: String) throws -> Data? {
        lock.lock(); defer { lock.unlock() }
        return storage[key]
    }

    public func setData(_ data: Data?, forKey key: String) throws {
        lock.lock(); defer { lock.unlock() }
        storage[key] = data
    }

    public func removeValue(forKey key: String) throws {
        lock.lock(); defer { lock.unlock() }
        storage.removeValue(forKey: key)
        bools.removeValue(forKey: key)
        strings.removeValue(forKey: key)
    }

    public func bool(forKey key: String) -> Bool {
        lock.lock(); defer { lock.unlock() }
        return bools[key] ?? false
    }

    public func setBool(_ value: Bool, forKey key: String) {
        lock.lock(); defer { lock.unlock() }
        bools[key] = value
    }

    public func string(forKey key: String) -> String? {
        lock.lock(); defer { lock.unlock() }
        return strings[key]
    }

    public func setString(_ value: String?, forKey key: String) {
        lock.lock(); defer { lock.unlock() }
        strings[key] = value
    }
}
