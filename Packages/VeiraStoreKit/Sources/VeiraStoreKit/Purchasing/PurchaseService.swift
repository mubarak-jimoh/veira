import Foundation
import StoreKit
import VeiraCore
import VeiraDomain

public enum PurchaseError: VeiraError, Equatable {
    case productUnavailable
    case purchasePending
    case userCancelled
    case unverified
    case failed(message: String)

    public var userFacingMessage: String {
        switch self {
        case .productUnavailable:
            "This plan isn’t available right now."
        case .purchasePending:
            "Your purchase is pending approval."
        case .userCancelled:
            "Purchase cancelled."
        case .unverified:
            "We couldn’t verify this purchase. Please contact support."
        case .failed:
            "Purchase failed. Please try again."
        }
    }

    public var isRetryable: Bool {
        switch self {
        case .productUnavailable, .failed:
            true
        case .purchasePending, .userCancelled, .unverified:
            false
        }
    }
}

public protocol PurchaseService: Sendable {
    func loadProducts() async throws -> [VeiraProduct]
    func purchase(_ productID: VeiraProductID) async throws -> SubscriptionEntitlement
    func restorePurchases() async throws -> SubscriptionEntitlement
    func currentEntitlement() async -> SubscriptionEntitlement
}
