import Foundation

/// Runtime environment for the Veira application.
///
/// Selected at composition-root construction time from build configuration.
/// Never read `DEBUG` flags from feature code — inject `AppEnvironment` instead.
public enum AppEnvironment: String, Sendable, CaseIterable, Equatable {
    case development
    case staging
    case production

    public var isProduction: Bool { self == .production }

    public var displayName: String {
        switch self {
        case .development: "Development"
        case .staging: "Staging"
        case .production: "Production"
        }
    }
}

/// Immutable configuration for the active environment.
public struct EnvironmentConfiguration: Sendable, Equatable {
    public let environment: AppEnvironment
    public let apiBaseURL: URL
    public let analyticsEnabled: Bool
    public let loggingLevel: LogLevel
    public let bundleIdentifier: String
    public let appVersion: String
    public let buildNumber: String

    public init(
        environment: AppEnvironment,
        apiBaseURL: URL,
        analyticsEnabled: Bool,
        loggingLevel: LogLevel,
        bundleIdentifier: String,
        appVersion: String,
        buildNumber: String
    ) {
        self.environment = environment
        self.apiBaseURL = apiBaseURL
        self.analyticsEnabled = analyticsEnabled
        self.loggingLevel = loggingLevel
        self.bundleIdentifier = bundleIdentifier
        self.appVersion = appVersion
        self.buildNumber = buildNumber
    }
}

/// Factory that maps build settings / Info.plist into a typed configuration.
public enum EnvironmentConfigurationFactory: Sendable {

    public static func make(
        bundle: Bundle = .main,
        processInfo: ProcessInfo = .processInfo
    ) -> EnvironmentConfiguration {
        let environment = resolveEnvironment(bundle: bundle, processInfo: processInfo)
        let info = bundle.infoDictionary ?? [:]

        let version = info["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let build = info["CFBundleVersion"] as? String ?? "0"
        let bundleID = bundle.bundleIdentifier ?? "com.veira.app"

        return EnvironmentConfiguration(
            environment: environment,
            apiBaseURL: apiBaseURL(for: environment, info: info),
            analyticsEnabled: environment != .development,
            loggingLevel: loggingLevel(for: environment),
            bundleIdentifier: bundleID,
            appVersion: version,
            buildNumber: build
        )
    }

    private static func resolveEnvironment(
        bundle: Bundle,
        processInfo: ProcessInfo
    ) -> AppEnvironment {
        if let override = processInfo.environment["VEIRA_ENVIRONMENT"],
           let parsed = AppEnvironment(rawValue: override.lowercased()) {
            return parsed
        }

        let info = bundle.infoDictionary ?? [:]
        if let raw = info["VeiraEnvironment"] as? String,
           let parsed = AppEnvironment(rawValue: raw.lowercased()) {
            return parsed
        }

        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    private static func apiBaseURL(for environment: AppEnvironment, info: [String: Any]) -> URL {
        let key: String = switch environment {
        case .development: "VeiraAPIBaseURLDevelopment"
        case .staging: "VeiraAPIBaseURLStaging"
        case .production: "VeiraAPIBaseURLProduction"
        }

        if let raw = info[key] as? String,
           let url = URL(string: raw) {
            return url
        }

        // Safe defaults — replace via Info.plist / xcconfig before shipping.
        switch environment {
        case .development:
            return URL(string: "https://api.dev.veira.app/v1")!
        case .staging:
            return URL(string: "https://api.staging.veira.app/v1")!
        case .production:
            return URL(string: "https://api.veira.app/v1")!
        }
    }

    private static func loggingLevel(for environment: AppEnvironment) -> LogLevel {
        switch environment {
        case .development: .debug
        case .staging: .info
        case .production: .warning
        }
    }
}
