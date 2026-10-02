import Foundation
import Observation
import SwiftUI
import VeiraCore
import VeiraData
import VeiraDomain
import VeiraNetworking
import VeiraStoreKit

/// Composition root — the only place concrete implementations are constructed.
@MainActor
@Observable
public final class AppContainer {
    public let configuration: EnvironmentConfiguration
    public let logger: any Logging
    public let analytics: any AnalyticsClient
    public let apiClient: any APIClient
    public let sessionRepository: any SessionRepository
    public let preferencesRepository: any PreferencesRepository
    public let purchaseService: any PurchaseService
    public let entitlementStore: EntitlementStore
    public let fileStore: any FileStore
    public let clock: any ClockProviding
    public let router: AppRouter
    public let authService: AuthService
    public let dependencyValues: DependencyValues

    /// Resolved appearance override: `nil` follows system.
    public var preferredColorScheme: ColorScheme?

    public init(configuration: EnvironmentConfiguration) {
        self.configuration = configuration

        let logger: any Logging = OSLogger(
            subsystem: configuration.bundleIdentifier,
            minimumLevel: configuration.loggingLevel
        )
        self.logger = logger

        let clock = SystemClock()
        self.clock = clock

        let keychain = SystemKeychainStore(service: configuration.bundleIdentifier)
        let sessionRepository = KeychainSessionRepository(keychain: keychain)
        self.sessionRepository = sessionRepository

        let preferences = LocalPreferencesRepository(
            store: UserDefaultsKeyValueStore(suiteName: configuration.bundleIdentifier)
        )
        self.preferencesRepository = preferences

        self.fileStore = DiskFileStore(logger: logger)

        let loggingAnalytics = LoggingAnalyticsClient(logger: logger)
        let analytics: any AnalyticsClient = GatedAnalyticsClient(underlying: loggingAnalytics) {
            guard configuration.analyticsEnabled else { return false }
            let optedIn = await preferences.bool(for: .analyticsOptIn)
            let hasOnboarded = await preferences.bool(for: .hasCompletedOnboarding)
            return hasOnboarded ? optedIn : configuration.analyticsEnabled
        }
        self.analytics = analytics

        let headers = DefaultHeadersInterceptor(
            appVersion: configuration.appVersion,
            buildNumber: configuration.buildNumber,
            bundleIdentifier: configuration.bundleIdentifier
        )
        let requestID = RequestIDInterceptor()

        let refreshClient = URLSessionHTTPClient(
            baseURL: configuration.apiBaseURL,
            requestInterceptors: [headers, requestID],
            responseInterceptors: [],
            retryPolicy: .standard,
            tokenRefresher: nil,
            logger: logger
        )

        let tokenRefresher = SessionTokenRefresher(
            sessionRepository: sessionRepository,
            httpClient: refreshClient,
            logger: logger
        )

        let auth = AuthenticationInterceptor {
            try await sessionRepository.currentSession()?.accessToken
        }

        let responseLogger = LoggingResponseInterceptor { message in
            logger.debug(message, category: .networking)
        }

        let httpClient = URLSessionHTTPClient(
            baseURL: configuration.apiBaseURL,
            requestInterceptors: [headers, requestID, auth],
            responseInterceptors: [responseLogger],
            retryPolicy: .standard,
            tokenRefresher: tokenRefresher,
            logger: logger
        )
        self.apiClient = LiveAPIClient(httpClient: httpClient)

        let storeKit = StoreKitPurchaseService(logger: logger, clock: clock)
        self.purchaseService = storeKit
        self.entitlementStore = EntitlementStore(purchaseService: storeKit, logger: logger)

        self.router = AppRouter()
        self.preferredColorScheme = nil

        self.authService = AuthService(
            sessionRepository: sessionRepository,
            preferencesRepository: preferences,
            logger: logger,
            clock: clock
        )

        var values = DependencyValues()
        values.logger = logger
        values.analytics = analytics
        values.clock = clock
        values.environment = configuration
        self.dependencyValues = values
    }

    public func start() async {
        logger.info(
            "Veira starting (\(configuration.environment.displayName)) v\(configuration.appVersion) (\(configuration.buildNumber))",
            category: .app
        )

        // Brief splash so the brand mark can settle before the first interactive surface.
        try? await Task.sleep(for: .milliseconds(900))

        await loadAppearancePreference()
        await entitlementStore.start()
        _ = try? await entitlementStore.refresh()

        let completedOnboarding = await preferencesRepository.bool(for: .hasCompletedOnboarding)
        let completedPermissions = await preferencesRepository.bool(for: .hasCompletedPermissions)
        let session = try? await sessionRepository.currentSession()
        let isAuthenticated = session != nil && !(session?.isExpired() ?? true)

        router.applyLaunchState(
            hasCompletedOnboarding: completedOnboarding,
            isAuthenticated: isAuthenticated,
            hasCompletedPermissions: completedPermissions
        )
    }

    public func completeOnboardingFunnel() async {
        await preferencesRepository.setBool(true, for: .hasCompletedOnboarding)
        await preferencesRepository.setBool(
            configuration.analyticsEnabled,
            for: .analyticsOptIn
        )
        await analytics.track(AnalyticsEvent(name: "onboarding_completed"))
        router.showAuthentication()
    }

    public func setPreferredColorScheme(_ scheme: ColorScheme?) async {
        preferredColorScheme = scheme
        let value: String? = switch scheme {
        case .some(.light): "light"
        case .some(.dark): "dark"
        case .none: nil
        @unknown default: nil
        }
        await preferencesRepository.setString(value, for: .preferredColorScheme)
    }

    /// Runs work with task-local dependencies bound to this container.
    public func withDependencies<T>(
        _ operation: () async throws -> T
    ) async rethrows -> T {
        try await Dependencies.$current.withValue(dependencyValues, operation: operation)
    }

    private func loadAppearancePreference() async {
        switch await preferencesRepository.string(for: .preferredColorScheme) {
        case "light": preferredColorScheme = .light
        case "dark": preferredColorScheme = .dark
        default: preferredColorScheme = nil
        }
    }
}
