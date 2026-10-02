import Foundation
import VeiraDomain
import VeiraNetworking

/// API route catalogue — feature endpoints are added here as they ship.
///
/// Keeping routes in one place prevents path drift across repositories.
public enum VeiraAPI {
    public enum Auth {
        public static func refresh(refreshToken: String) throws -> Endpoint {
            struct Body: Encodable { let refreshToken: String }
            return try Endpoint.json(
                "/auth/refresh",
                method: .post,
                body: Body(refreshToken: refreshToken),
                requiresAuthentication: false
            )
        }
    }

    public enum Me {
        public static var profile: Endpoint {
            .get("/me")
        }
    }

    public enum Health {
        public static var ping: Endpoint {
            .get("/health", requiresAuthentication: false)
        }
    }
}

/// Thin facade over HTTPClient for domain-facing API access.
public protocol APIClient: Sendable {
    func send(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse)
    func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response
}

public struct LiveAPIClient: APIClient {
    private let httpClient: any HTTPClient

    public init(httpClient: any HTTPClient) {
        self.httpClient = httpClient
    }

    public func send(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        try await httpClient.send(endpoint)
    }

    public func send<Response: Decodable>(_ endpoint: Endpoint) async throws -> Response {
        try await httpClient.send(endpoint)
    }
}
