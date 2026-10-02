import Foundation
import VeiraDomain

/// Deterministic purchase service for previews and unit tests.
public actor MockPurchaseService: PurchaseService {
    private var entitlement: SubscriptionEntitlement
    private let products: [VeiraProduct]

    public init(
        entitlement: SubscriptionEntitlement = .none,
        products: [VeiraProduct] = [
            VeiraProduct(
                id: .premiumMonthly,
                displayName: "Monthly",
                description: "Veira Premium",
                displayPrice: "$12.99",
                price: 12.99
            ),
            VeiraProduct(
                id: .premiumYearly,
                displayName: "Yearly",
                description: "Veira Premium",
                displayPrice: "$89.99",
                price: 89.99
            )
        ]
    ) {
        self.entitlement = entitlement
        self.products = products
    }

    public func loadProducts() async throws -> [VeiraProduct] {
        products
    }

    public func purchase(_ productID: VeiraProductID) async throws -> SubscriptionEntitlement {
        entitlement = SubscriptionEntitlement(
            productID: productID.rawValue,
            status: .active,
            expiresAt: Date().addingTimeInterval(30 * 24 * 3600),
            willAutoRenew: true
        )
        return entitlement
    }

    public func restorePurchases() async throws -> SubscriptionEntitlement {
        entitlement
    }

    public func currentEntitlement() async -> SubscriptionEntitlement {
        entitlement
    }
}
