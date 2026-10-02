import Foundation
import VeiraDomain

/// Pure mapping from StoreKit facts → domain entitlement.
///
/// Kept free of StoreKit types so unit tests can assert policy without device APIs.
public enum EntitlementMapper: Sendable {

    public struct Facts: Sendable, Equatable {
        public let productID: String
        public let revocationDate: Date?
        public let expirationDate: Date?
        public let willAutoRenew: Bool
        public let isInBillingRetry: Bool
        public let isInGracePeriod: Bool
        public let isIntroductoryOffer: Bool
        public let now: Date

        public init(
            productID: String,
            revocationDate: Date?,
            expirationDate: Date?,
            willAutoRenew: Bool,
            isInBillingRetry: Bool,
            isInGracePeriod: Bool,
            isIntroductoryOffer: Bool,
            now: Date
        ) {
            self.productID = productID
            self.revocationDate = revocationDate
            self.expirationDate = expirationDate
            self.willAutoRenew = willAutoRenew
            self.isInBillingRetry = isInBillingRetry
            self.isInGracePeriod = isInGracePeriod
            self.isIntroductoryOffer = isIntroductoryOffer
            self.now = now
        }
    }

    public static func map(_ facts: Facts) -> SubscriptionEntitlement {
        let status: SubscriptionStatus

        if facts.revocationDate != nil {
            status = .revoked
        } else if facts.isInBillingRetry {
            status = .billingRetry
        } else if let expiration = facts.expirationDate, expiration < facts.now, !facts.isInGracePeriod {
            status = .expired
        } else if facts.isIntroductoryOffer {
            status = .trial
        } else if facts.isInGracePeriod || facts.expirationDate == nil || facts.expirationDate! >= facts.now {
            status = .active
        } else {
            status = .expired
        }

        return SubscriptionEntitlement(
            productID: facts.productID,
            status: status,
            expiresAt: facts.expirationDate,
            willAutoRenew: facts.willAutoRenew
        )
    }

    /// Chooses the strongest entitlement when multiple products are active.
    public static func preferred(
        _ lhs: SubscriptionEntitlement,
        _ rhs: SubscriptionEntitlement
    ) -> SubscriptionEntitlement {
        rank(lhs) >= rank(rhs) ? lhs : rhs
    }

    private static func rank(_ entitlement: SubscriptionEntitlement) -> Int {
        switch entitlement.status {
        case .active: 5
        case .trial: 4
        case .billingRetry: 3
        case .expired: 2
        case .revoked: 1
        case .none: 0
        }
    }
}
