import Foundation

/// Persistence contract for auth session — implemented in VeiraData.
public protocol SessionRepository: Sendable {
    func currentSession() async throws -> UserSession?
    func save(_ session: UserSession) async throws
    func clear() async throws
}

/// Persistence contract for local preferences / onboarding flags.
public protocol PreferencesRepository: Sendable {
    func bool(for key: PreferenceKey) async -> Bool
    func setBool(_ value: Bool, for key: PreferenceKey) async
    func string(for key: PreferenceKey) async -> String?
    func setString(_ value: String?, for key: PreferenceKey) async
}

public struct PreferenceKey: RawRepresentable, Sendable, Hashable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let hasCompletedOnboarding = PreferenceKey(rawValue: "has_completed_onboarding")
    public static let hasCompletedPermissions = PreferenceKey(rawValue: "has_completed_permissions")
    public static let preferredColorScheme = PreferenceKey(rawValue: "preferred_color_scheme")
    public static let analyticsOptIn = PreferenceKey(rawValue: "analytics_opt_in")
    public static let displayName = PreferenceKey(rawValue: "display_name")
    public static let accountEmail = PreferenceKey(rawValue: "account_email")
    public static let skinGoal = PreferenceKey(rawValue: "skin_goal")
}

/// Contract for reading subscription entitlements.
public protocol EntitlementRepository: Sendable {
    func currentEntitlement() async -> SubscriptionEntitlement
    func refresh() async throws -> SubscriptionEntitlement
}
