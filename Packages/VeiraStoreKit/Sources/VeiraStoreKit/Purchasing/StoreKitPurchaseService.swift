import Foundation
import StoreKit
import VeiraCore
import VeiraDomain

/// StoreKit 2 purchase implementation.
public actor StoreKitPurchaseService: PurchaseService {
    private let logger: any Logging
    private let clock: any ClockProviding
    private var productsByID: [VeiraProductID: Product] = [:]

    public init(logger: any Logging, clock: any ClockProviding = SystemClock()) {
        self.logger = logger
        self.clock = clock
    }

    public func loadProducts() async throws -> [VeiraProduct] {
        let ids = VeiraProductID.allCases.map(\.rawValue)
        let products = try await Product.products(for: ids)

        var mapped: [VeiraProduct] = []
        productsByID.removeAll()

        for product in products {
            guard let id = VeiraProductID(rawValue: product.id) else { continue }
            productsByID[id] = product
            mapped.append(
                VeiraProduct(
                    id: id,
                    displayName: product.displayName,
                    description: product.description,
                    displayPrice: product.displayPrice,
                    price: product.price
                )
            )
        }

        logger.info("Loaded \(mapped.count) StoreKit products", category: .storeKit)
        return mapped.sorted { $0.id.rawValue < $1.id.rawValue }
    }

    public func purchase(_ productID: VeiraProductID) async throws -> SubscriptionEntitlement {
        let product: Product
        if let cached = productsByID[productID] {
            product = cached
        } else if let fetched = try await fetchProduct(productID) {
            product = fetched
        } else {
            throw PurchaseError.productUnavailable
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            logger.info("Purchase succeeded for \(productID.rawValue)", category: .storeKit)
            return await currentEntitlement()

        case .userCancelled:
            throw PurchaseError.userCancelled

        case .pending:
            throw PurchaseError.purchasePending

        @unknown default:
            throw PurchaseError.failed(message: "Unknown purchase result")
        }
    }

    public func restorePurchases() async throws -> SubscriptionEntitlement {
        try await AppStore.sync()
        logger.info("Restored purchases via AppStore.sync", category: .storeKit)
        return await currentEntitlement()
    }

    public func currentEntitlement() async -> SubscriptionEntitlement {
        var preferred = SubscriptionEntitlement.none
        let now = clock.now()

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard VeiraProductID(rawValue: transaction.productID) != nil else { continue }

            let subscriptionState = await subscriptionState(for: transaction.productID)
            let mapped = EntitlementMapper.map(
                EntitlementMapper.Facts(
                    productID: transaction.productID,
                    revocationDate: transaction.revocationDate,
                    expirationDate: transaction.expirationDate,
                    willAutoRenew: subscriptionState.willAutoRenew,
                    isInBillingRetry: subscriptionState.isInBillingRetry,
                    isInGracePeriod: subscriptionState.isInGracePeriod,
                    isIntroductoryOffer: transaction.offerType == .introductory,
                    now: now
                )
            )
            preferred = EntitlementMapper.preferred(preferred, mapped)
        }

        return preferred
    }

    private struct SubscriptionState {
        var willAutoRenew = false
        var isInBillingRetry = false
        var isInGracePeriod = false
    }

    private func subscriptionState(for productID: String) async -> SubscriptionState {
        var state = SubscriptionState()

        guard let product = try? await Product.products(for: [productID]).first,
              let subscription = product.subscription,
              let statuses = try? await subscription.status
        else {
            return state
        }

        for status in statuses {
            guard case .verified(let renewal) = status.renewalInfo else { continue }
            state.willAutoRenew = renewal.willAutoRenew

            switch status.state {
            case .inBillingRetryPeriod:
                state.isInBillingRetry = true
            case .inGracePeriod:
                state.isInGracePeriod = true
            default:
                break
            }
        }

        return state
    }

    private func fetchProduct(_ id: VeiraProductID) async throws -> Product? {
        let products = try await Product.products(for: [id.rawValue])
        if let product = products.first {
            productsByID[id] = product
        }
        return products.first
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.unverified
        case .verified(let safe):
            return safe
        }
    }
}
