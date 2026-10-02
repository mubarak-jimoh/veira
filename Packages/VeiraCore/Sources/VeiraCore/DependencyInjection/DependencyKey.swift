import Foundation

/// Type-safe dependency key, mirroring SwiftUI's EnvironmentKey pattern
/// without coupling Core to SwiftUI.
public protocol DependencyKey: Sendable {
    associatedtype Value: Sendable
    static var defaultValue: Value { get }
}

/// Global dependency values — configured only at the composition root.
public struct DependencyValues: Sendable {
    private var storage: [ObjectIdentifier: any Sendable] = [:]

    public init() {}

    public subscript<K: DependencyKey>(key: K.Type) -> K.Value {
        get {
            if let value = storage[ObjectIdentifier(key)] as? K.Value {
                return value
            }
            return key.defaultValue
        }
        set {
            storage[ObjectIdentifier(key)] = newValue
        }
    }
}

/// Task-local dependency values for structured concurrency contexts.
public enum Dependencies {
    @TaskLocal public static var current = DependencyValues()

    public static func with<T>(
        _ update: (inout DependencyValues) -> Void,
        operation: () async throws -> T
    ) async rethrows -> T {
        var values = current
        update(&values)
        return try await $current.withValue(values, operation: operation)
    }

    public static func with<T>(
        _ update: (inout DependencyValues) -> Void,
        operation: () throws -> T
    ) rethrows -> T {
        var values = current
        update(&values)
        return try $current.withValue(values, operation: operation)
    }
}
