import Foundation

/// Subscription entitlement state — domain-level, independent of StoreKit.
public enum SubscriptionStatus: String, Sendable, Codable, Equatable {
    case none
    case trial
    case active
    case expired
    case revoked
    case billingRetry

    public var isPremium: Bool {
        switch self {
        case .trial, .active: true
        case .none, .expired, .revoked, .billingRetry: false
        }
    }
}

public struct SubscriptionEntitlement: Sendable, Equatable, Codable {
    public let productID: String
    public let status: SubscriptionStatus
    public let expiresAt: Date?
    public let willAutoRenew: Bool

    public init(
        productID: String,
        status: SubscriptionStatus,
        expiresAt: Date?,
        willAutoRenew: Bool
    ) {
        self.productID = productID
        self.status = status
        self.expiresAt = expiresAt
        self.willAutoRenew = willAutoRenew
    }

    public static let none = SubscriptionEntitlement(
        productID: "",
        status: .none,
        expiresAt: nil,
        willAutoRenew: false
    )
}
