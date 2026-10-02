import Foundation
import StoreKit
import VeiraCore
import VeiraDomain

/// Observes entitlement changes and exposes the current premium state.
public actor EntitlementStore: EntitlementRepository {
    private let purchaseService: any PurchaseService
    private let logger: any Logging
    private var cached: SubscriptionEntitlement = .none
    private var listenTask: Task<Void, Never>?

    public init(purchaseService: any PurchaseService, logger: any Logging) {
        self.purchaseService = purchaseService
        self.logger = logger
    }

    public func start() {
        guard listenTask == nil else { return }
        listenTask = Task { [weak self] in
            guard let self else { return }
            for await _ in Transaction.updates {
                let entitlement = await self.purchaseService.currentEntitlement()
                await self.updateCache(entitlement)
            }
        }
    }

    public func stop() {
        listenTask?.cancel()
        listenTask = nil
    }

    public func currentEntitlement() async -> SubscriptionEntitlement {
        cached
    }

    public func refresh() async throws -> SubscriptionEntitlement {
        let entitlement = await purchaseService.currentEntitlement()
        cached = entitlement
        logger.info(
            "Entitlement refresh: \(entitlement.status.rawValue)",
            category: .storeKit
        )
        return entitlement
    }

    private func updateCache(_ entitlement: SubscriptionEntitlement) {
        cached = entitlement
    }
}
