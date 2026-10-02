import XCTest
@testable import VeiraDomain

final class SkinScoreTests: XCTestCase {
    private func score(_ value: Int) -> SkinScore {
        SkinScore(value: value, capturedAt: Date(timeIntervalSince1970: 0), summary: "", metrics: [])
    }

    func testValuesAreClampedToZeroThroughOneHundred() {
        XCTAssertEqual(score(-5).value, 0)
        XCTAssertEqual(score(150).value, 100)
        XCTAssertEqual(score(64).value, 64)
    }

    func testBandsChangeAtTheirBoundaries() {
        XCTAssertEqual(score(100).band, .excellent)
        XCTAssertEqual(score(85).band, .excellent)
        XCTAssertEqual(score(84).band, .good)
        XCTAssertEqual(score(70).band, .good)
        XCTAssertEqual(score(69).band, .fair)
        XCTAssertEqual(score(55).band, .fair)
        XCTAssertEqual(score(54).band, .needsAttention)
        XCTAssertEqual(score(0).band, .needsAttention)
    }

    func testProgressIsAFractionOfOne() {
        XCTAssertEqual(score(0).normalizedProgress, 0)
        XCTAssertEqual(score(50).normalizedProgress, 0.5)
        XCTAssertEqual(score(100).normalizedProgress, 1)
    }

    func testSurvivesAnEncodeAndDecodeRoundTrip() throws {
        let metric = SkinMetric(name: "Hydration", value: 72, insight: "Steady", symbolName: "drop")
        let original = SkinScore(
            value: 81,
            capturedAt: Date(timeIntervalSince1970: 1_700_000_000),
            summary: "Good day",
            metrics: [metric]
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(SkinScore.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func testMetricValuesAreClampedToo() {
        let metric = SkinMetric(name: "Texture", value: 400, insight: "", symbolName: "sparkles")
        XCTAssertEqual(metric.value, 100)
        XCTAssertEqual(metric.normalizedProgress, 1)
    }
}

final class SkinRoutineTests: XCTestCase {
    private func step(done: Bool) -> RoutineStep {
        RoutineStep(title: "Cleanse", detail: "", durationSeconds: 60, isCompleted: done, symbolName: "drop")
    }

    func testAnEmptyRoutineHasNoProgressAndDoesNotDivideByZero() {
        let routine = SkinRoutine(title: "Morning", period: .morning, steps: [], estimatedMinutes: 0)
        XCTAssertEqual(routine.completionProgress, 0)
        XCTAssertEqual(routine.completedCount, 0)
    }

    func testProgressIsTheShareOfCompletedSteps() {
        let routine = SkinRoutine(
            title: "Evening",
            period: .evening,
            steps: [step(done: true), step(done: false), step(done: true), step(done: false)],
            estimatedMinutes: 6
        )
        XCTAssertEqual(routine.completedCount, 2)
        XCTAssertEqual(routine.completionProgress, 0.5)
    }

    func testAFinishedRoutineIsFullyComplete() {
        let routine = SkinRoutine(
            title: "Morning",
            period: .morning,
            steps: [step(done: true), step(done: true)],
            estimatedMinutes: 4
        )
        XCTAssertEqual(routine.completionProgress, 1)
    }
}

final class ProfileAndProgressTests: XCTestCase {
    func testProgressScoresAreClamped() {
        let low = ProgressSnapshot(weekLabel: "W1", score: -10, note: "", capturedAt: Date())
        let high = ProgressSnapshot(weekLabel: "W2", score: 999, note: "", capturedAt: Date())
        XCTAssertEqual(low.score, 0)
        XCTAssertEqual(high.score, 100)
    }

    func testFirstNameIsTheFirstWordOfTheDisplayName() {
        func profile(_ name: String) -> UserProfile {
            UserProfile(displayName: name, email: "a@example.com", skinGoal: "", memberSince: Date())
        }
        XCTAssertEqual(profile("Ada Lovelace").firstName, "Ada")
        XCTAssertEqual(profile("Cher").firstName, "Cher")
        XCTAssertEqual(profile("").firstName, "")
    }
}

final class UserSessionExpiryTests: XCTestCase {
    private let expiry = Date(timeIntervalSince1970: 1_700_000_000)

    private var session: UserSession {
        UserSession(userID: "user_1", accessToken: "a", refreshToken: "r", expiresAt: expiry)
    }

    func testASessionIsValidUntilItsExpiry() {
        XCTAssertFalse(session.isExpired(at: expiry.addingTimeInterval(-1)))
    }

    func testASessionIsExpiredAtAndAfterItsExpiry() {
        XCTAssertTrue(session.isExpired(at: expiry))
        XCTAssertTrue(session.isExpired(at: expiry.addingTimeInterval(60)))
    }

    func testExpiryIsStoredToTheMillisecond() {
        let precise = UserSession(
            userID: "user_1",
            accessToken: "a",
            refreshToken: "r",
            expiresAt: Date(timeIntervalSince1970: 1_700_000_000.123_456)
        )
        XCTAssertEqual(precise.expiresAt.timeIntervalSince1970, 1_700_000_000.123, accuracy: 0.000_1)
    }
}
