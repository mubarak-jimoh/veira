import XCTest
@testable import VeiraCore

final class EnvironmentConfigurationTests: XCTestCase {
    func testDevelopmentDefaultsDisableAnalytics() {
        let config = EnvironmentConfiguration(
            environment: .development,
            apiBaseURL: URL(string: "https://api.dev.veira.app/v1")!,
            analyticsEnabled: false,
            loggingLevel: .debug,
            bundleIdentifier: "com.veira.app",
            appVersion: "1.0.0",
            buildNumber: "1"
        )

        XCTAssertEqual(config.environment, .development)
        XCTAssertFalse(config.analyticsEnabled)
        XCTAssertEqual(config.loggingLevel, .debug)
    }

    func testProductionIsProduction() {
        XCTAssertTrue(AppEnvironment.production.isProduction)
        XCTAssertFalse(AppEnvironment.staging.isProduction)
    }
}

final class InMemoryLoggerTests: XCTestCase {
    func testRecordsEntries() {
        let logger = InMemoryLogger()
        logger.info("hello", category: .app)
        XCTAssertEqual(logger.entries.count, 1)
        XCTAssertEqual(logger.entries[0].message, "hello")
        XCTAssertEqual(logger.entries[0].level, .info)
    }
}

final class LogLevelTests: XCTestCase {
    func testOrdering() {
        XCTAssertTrue(LogLevel.debug < LogLevel.info)
        XCTAssertTrue(LogLevel.info < LogLevel.warning)
        XCTAssertTrue(LogLevel.warning < LogLevel.error)
        XCTAssertTrue(LogLevel.error < LogLevel.fault)
    }
}
