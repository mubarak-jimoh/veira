import Foundation

/// Canonical StoreKit product identifiers for Veira Premium.
///
/// Keep App Store Connect IDs in sync with this enum — never hardcode strings in UI.
public enum VeiraProductID: String, Sendable, CaseIterable, Identifiable {
    case premiumMonthly = "com.veira.premium.monthly"
    case premiumYearly = "com.veira.premium.yearly"

    public var id: String { rawValue }

    public var displayName: String {
        switch self {
        case .premiumMonthly: "Veira Premium Monthly"
        case .premiumYearly: "Veira Premium Yearly"
        }
    }
}

/// Domain-facing product model (decoupled from StoreKit.Product for testability).
public struct VeiraProduct: Sendable, Equatable, Identifiable {
    public let id: VeiraProductID
    public let displayName: String
    public let description: String
    public let displayPrice: String
    public let price: Decimal

    public init(
        id: VeiraProductID,
        displayName: String,
        description: String,
        displayPrice: String,
        price: Decimal
    ) {
        self.id = id
        self.displayName = displayName
        self.description = description
        self.displayPrice = displayPrice
        self.price = price
    }
}
