import Foundation

private enum LoggerDependencyKey: DependencyKey {
    static let defaultValue: any Logging = NoOpLogger()
}

private enum AnalyticsDependencyKey: DependencyKey {
    static let defaultValue: any AnalyticsClient = NoOpAnalyticsClient()
}

private enum ClockDependencyKey: DependencyKey {
    static let defaultValue: any ClockProviding = SystemClock()
}

private enum EnvironmentDependencyKey: DependencyKey {
    static let defaultValue = EnvironmentConfiguration(
        environment: .development,
        apiBaseURL: URL(string: "https://api.dev.veira.app/v1")!,
        analyticsEnabled: false,
        loggingLevel: .debug,
        bundleIdentifier: "com.veira.app",
        appVersion: "0.0.0",
        buildNumber: "0"
    )
}

public extension DependencyValues {
    var logger: any Logging {
        get { self[LoggerDependencyKey.self] }
        set { self[LoggerDependencyKey.self] = newValue }
    }

    var analytics: any AnalyticsClient {
        get { self[AnalyticsDependencyKey.self] }
        set { self[AnalyticsDependencyKey.self] = newValue }
    }

    var clock: any ClockProviding {
        get { self[ClockDependencyKey.self] }
        set { self[ClockDependencyKey.self] = newValue }
    }

    var environment: EnvironmentConfiguration {
        get { self[EnvironmentDependencyKey.self] }
        set { self[EnvironmentDependencyKey.self] = newValue }
    }
}
