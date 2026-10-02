import Foundation

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

/// Describes a single API request without performing it.
public struct Endpoint: Sendable {
    public let path: String
    public let method: HTTPMethod
    public let queryItems: [URLQueryItem]
    public let headers: [String: String]
    public let body: Data?
    public let requiresAuthentication: Bool
    public let timeout: TimeInterval

    public init(
        path: String,
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil,
        requiresAuthentication: Bool = true,
        timeout: TimeInterval = 30
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
        self.requiresAuthentication = requiresAuthentication
        self.timeout = timeout
    }

    public static func get(
        _ path: String,
        queryItems: [URLQueryItem] = [],
        requiresAuthentication: Bool = true
    ) -> Endpoint {
        Endpoint(
            path: path,
            method: .get,
            queryItems: queryItems,
            requiresAuthentication: requiresAuthentication
        )
    }

    public static func json<Body: Encodable>(
        _ path: String,
        method: HTTPMethod,
        body: Body,
        encoder: JSONEncoder = APIJSONCoding.encoder,
        requiresAuthentication: Bool = true
    ) throws -> Endpoint {
        Endpoint(
            path: path,
            method: method,
            headers: ["Content-Type": "application/json"],
            body: try encoder.encode(body),
            requiresAuthentication: requiresAuthentication
        )
    }
}

public enum APIJSONCoding {
    public static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}
