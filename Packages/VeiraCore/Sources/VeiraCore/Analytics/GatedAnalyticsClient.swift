import Foundation

/// Analytics client that only forwards events when the user has opted in
/// and the environment allows analytics.
public struct GatedAnalyticsClient: AnalyticsClient {
    private let underlying: any AnalyticsClient
    private let isEnabled: @Sendable () async -> Bool

    public init(
        underlying: any AnalyticsClient,
        isEnabled: @escaping @Sendable () async -> Bool
    ) {
        self.underlying = underlying
        self.isEnabled = isEnabled
    }

    public func track(_ event: AnalyticsEvent) async {
        guard await isEnabled() else { return }
        await underlying.track(event)
    }

    public func setUserID(_ userID: String?) async {
        guard await isEnabled() else { return }
        await underlying.setUserID(userID)
    }

    public func setUserProperty(_ property: AnalyticsUserProperty, value: String?) async {
        guard await isEnabled() else { return }
        await underlying.setUserProperty(property, value: value)
    }

    public func screen(name: String, parameters: [String: AnalyticsParameterValue]) async {
        guard await isEnabled() else { return }
        await underlying.screen(name: name, parameters: parameters)
    }
}
