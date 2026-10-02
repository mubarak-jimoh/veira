import Foundation

/// Analytics abstraction — swap providers without touching feature code.
public protocol AnalyticsClient: Sendable {
    func track(_ event: AnalyticsEvent) async
    func setUserID(_ userID: String?) async
    func setUserProperty(_ property: AnalyticsUserProperty, value: String?) async
    func screen(name: String, parameters: [String: AnalyticsParameterValue]) async
}

public extension AnalyticsClient {
    func screen(name: String) async {
        await screen(name: name, parameters: [:])
    }
}

/// Multiplexes events to multiple backends (e.g. product analytics + crash breadcrumbs).
public struct MultiplexAnalyticsClient: AnalyticsClient {
    private let clients: [any AnalyticsClient]

    public init(clients: [any AnalyticsClient]) {
        self.clients = clients
    }

    public func track(_ event: AnalyticsEvent) async {
        await withTaskGroup(of: Void.self) { group in
            for client in clients {
                group.addTask { await client.track(event) }
            }
        }
    }

    public func setUserID(_ userID: String?) async {
        await withTaskGroup(of: Void.self) { group in
            for client in clients {
                group.addTask { await client.setUserID(userID) }
            }
        }
    }

    public func setUserProperty(_ property: AnalyticsUserProperty, value: String?) async {
        await withTaskGroup(of: Void.self) { group in
            for client in clients {
                group.addTask { await client.setUserProperty(property, value: value) }
            }
        }
    }

    public func screen(name: String, parameters: [String: AnalyticsParameterValue]) async {
        await withTaskGroup(of: Void.self) { group in
            for client in clients {
                group.addTask { await client.screen(name: name, parameters: parameters) }
            }
        }
    }
}

/// Logs analytics calls — used in development and as a breadcrumb sink.
public struct LoggingAnalyticsClient: AnalyticsClient {
    private let logger: any Logging

    public init(logger: any Logging) {
        self.logger = logger
    }

    public func track(_ event: AnalyticsEvent) async {
        let params = event.parameters
            .map { "\($0.key)=\($0.value.stringValue)" }
            .sorted()
            .joined(separator: ", ")
        logger.debug(
            "track \(event.name) [\(params)]",
            category: .analytics
        )
    }

    public func setUserID(_ userID: String?) async {
        logger.debug("setUserID \(userID ?? "nil")", category: .analytics)
    }

    public func setUserProperty(_ property: AnalyticsUserProperty, value: String?) async {
        logger.debug(
            "setUserProperty \(property.name)=\(value ?? "nil")",
            category: .analytics
        )
    }

    public func screen(name: String, parameters: [String: AnalyticsParameterValue]) async {
        logger.debug("screen \(name)", category: .analytics)
    }
}

/// Drops all events — tests and privacy-restricted contexts.
public struct NoOpAnalyticsClient: AnalyticsClient {
    public init() {}

    public func track(_ event: AnalyticsEvent) async {}
    public func setUserID(_ userID: String?) async {}
    public func setUserProperty(_ property: AnalyticsUserProperty, value: String?) async {}
    public func screen(name: String, parameters: [String: AnalyticsParameterValue]) async {}
}

/// Records events for assertions in unit tests.
public actor RecordingAnalyticsClient: AnalyticsClient {
    public private(set) var events: [AnalyticsEvent] = []
    public private(set) var screens: [String] = []
    public private(set) var userID: String?

    public init() {}

    public func track(_ event: AnalyticsEvent) async {
        events.append(event)
    }

    public func setUserID(_ userID: String?) async {
        self.userID = userID
    }

    public func setUserProperty(_ property: AnalyticsUserProperty, value: String?) async {}

    public func screen(name: String, parameters: [String: AnalyticsParameterValue]) async {
        screens.append(name)
    }
}
