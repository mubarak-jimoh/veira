import Foundation

/// Mutates requests before they are sent (auth headers, tracing, etc.).
public protocol RequestInterceptor: Sendable {
    func intercept(_ request: URLRequest, endpoint: Endpoint) async throws -> URLRequest
}

/// Observes responses for logging, metrics, and diagnostics.
public protocol ResponseInterceptor: Sendable {
    func intercept(response: HTTPURLResponse, data: Data, endpoint: Endpoint) async throws
}

/// Injects Authorization bearer tokens when required.
public struct AuthenticationInterceptor: RequestInterceptor {
    public typealias TokenProvider = @Sendable () async throws -> String?

    private let tokenProvider: TokenProvider

    public init(tokenProvider: @escaping TokenProvider) {
        self.tokenProvider = tokenProvider
    }

    public func intercept(_ request: URLRequest, endpoint: Endpoint) async throws -> URLRequest {
        guard endpoint.requiresAuthentication else { return request }
        guard let token = try await tokenProvider() else {
            throw NetworkError.unauthorized
        }
        var mutable = request
        mutable.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return mutable
    }
}

/// Attaches standard Veira client headers.
public struct DefaultHeadersInterceptor: RequestInterceptor {
    private let appVersion: String
    private let buildNumber: String
    private let userAgent: String

    public init(appVersion: String, buildNumber: String, bundleIdentifier: String) {
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.userAgent = "Veira/\(appVersion) (\(bundleIdentifier); build:\(buildNumber))"
    }

    public func intercept(_ request: URLRequest, endpoint: Endpoint) async throws -> URLRequest {
        var mutable = request
        mutable.setValue("application/json", forHTTPHeaderField: "Accept")
        mutable.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        mutable.setValue(appVersion, forHTTPHeaderField: "X-Veira-App-Version")
        mutable.setValue(buildNumber, forHTTPHeaderField: "X-Veira-Build")
        return mutable
    }
}

/// Attaches a per-request correlation ID for distributed tracing.
public struct RequestIDInterceptor: RequestInterceptor {
    public init() {}

    public func intercept(_ request: URLRequest, endpoint: Endpoint) async throws -> URLRequest {
        var mutable = request
        if mutable.value(forHTTPHeaderField: "X-Request-ID") == nil {
            mutable.setValue(UUID().uuidString.lowercased(), forHTTPHeaderField: "X-Request-ID")
        }
        return mutable
    }
}

/// Emits structured response breadcrumbs without mutating the pipeline.
public struct LoggingResponseInterceptor: ResponseInterceptor {
    private let log: @Sendable (String) -> Void

    public init(log: @escaping @Sendable (String) -> Void) {
        self.log = log
    }

    public func intercept(response: HTTPURLResponse, data: Data, endpoint: Endpoint) async throws {
        log("\(endpoint.method.rawValue) \(endpoint.path) → \(response.statusCode) (\(data.count) bytes)")
    }
}
