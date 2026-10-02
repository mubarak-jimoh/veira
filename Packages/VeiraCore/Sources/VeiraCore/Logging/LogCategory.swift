import Foundation

/// Logical subsystem for log routing and filtering.
public struct LogCategory: RawRepresentable, Sendable, Hashable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public static let app: LogCategory = "app"
    public static let networking: LogCategory = "networking"
    public static let storage: LogCategory = "storage"
    public static let analytics: LogCategory = "analytics"
    public static let storeKit: LogCategory = "storekit"
    public static let ui: LogCategory = "ui"
    public static let auth: LogCategory = "auth"
}
