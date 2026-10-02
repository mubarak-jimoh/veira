import XCTest
@testable import VeiraDomain

final class SubscriptionStatusTests: XCTestCase {
    func testPremiumStates() {
        XCTAssertTrue(SubscriptionStatus.trial.isPremium)
        XCTAssertTrue(SubscriptionStatus.active.isPremium)
        XCTAssertFalse(SubscriptionStatus.none.isPremium)
        XCTAssertFalse(SubscriptionStatus.expired.isPremium)
    }
}

final class UserSessionTests: XCTestCase {
    func testExpiry() {
        let session = UserSession(
            userID: "user_1",
            accessToken: "a",
            refreshToken: "r",
            expiresAt: Date().addingTimeInterval(-1)
        )
        XCTAssertTrue(session.isExpired())
    }
}
