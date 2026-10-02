import XCTest
@testable import VeiraData
import VeiraDomain

final class PreferencesRepositoryTests: XCTestCase {
    func testBoolRoundTrip() async {
        let store = InMemoryKeyValueStore()
        let repo = LocalPreferencesRepository(store: store)

        await repo.setBool(true, for: .hasCompletedOnboarding)
        let value = await repo.bool(for: .hasCompletedOnboarding)
        XCTAssertTrue(value)
    }
}

final class SessionRepositoryTests: XCTestCase {
    func testSaveLoadClear() async throws {
        let keychain = InMemoryKeychainStore()
        let repo = KeychainSessionRepository(keychain: keychain)
        let session = UserSession(
            userID: "user_1",
            accessToken: "access",
            refreshToken: "refresh",
            expiresAt: Date().addingTimeInterval(3600)
        )

        try await repo.save(session)
        let loaded = try await repo.currentSession()
        XCTAssertEqual(loaded, session)

        try await repo.clear()
        let cleared = try await repo.currentSession()
        XCTAssertNil(cleared)
    }
}
