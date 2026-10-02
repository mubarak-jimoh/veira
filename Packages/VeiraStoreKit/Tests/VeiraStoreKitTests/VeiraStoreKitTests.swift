import XCTest
@testable import VeiraStoreKit

final class VeiraProductIDTests: XCTestCase {
    func testStableIdentifiers() {
        XCTAssertEqual(VeiraProductID.premiumMonthly.rawValue, "com.veira.premium.monthly")
        XCTAssertEqual(VeiraProductID.premiumYearly.rawValue, "com.veira.premium.yearly")
    }
}

final class MockPurchaseServiceTests: XCTestCase {
    func testPurchaseActivatesEntitlement() async throws {
        let service = MockPurchaseService()
        let entitlement = try await service.purchase(.premiumYearly)
        XCTAssertEqual(entitlement.status, .active)
        XCTAssertEqual(entitlement.productID, VeiraProductID.premiumYearly.rawValue)
    }
}
