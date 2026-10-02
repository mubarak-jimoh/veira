import Foundation

/// Strongly-typed analytics event.
///
/// Feature modules define their own events as static factories.
/// Raw string event names never leave the analytics boundary.
public struct AnalyticsEvent: Sendable, Equatable {
    public let name: String
    public let parameters: [String: AnalyticsParameterValue]

    public init(name: String, parameters: [String: AnalyticsParameterValue] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

/// Parameter values supported by analytics backends.
public enum AnalyticsParameterValue: Sendable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)

    public var stringValue: String {
        switch self {
        case .string(let value): value
        case .int(let value): String(value)
        case .double(let value): String(value)
        case .bool(let value): value ? "true" : "false"
        }
    }
}

/// User property keys for durable analytics traits.
public struct AnalyticsUserProperty: Sendable, Hashable {
    public let name: String

    public init(_ name: String) {
        self.name = name
    }

    public static let subscriptionStatus = AnalyticsUserProperty("subscription_status")
    public static let onboardingCompleted = AnalyticsUserProperty("onboarding_completed")
}
