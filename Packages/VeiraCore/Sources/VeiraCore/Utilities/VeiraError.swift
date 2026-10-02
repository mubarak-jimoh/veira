import Foundation

/// Base protocol for domain and infrastructure errors that can surface to UI.
public protocol VeiraError: Error, Sendable {
    var userFacingMessage: String { get }
    var isRetryable: Bool { get }
}

/// Generic infrastructure failures shared across layers.
public enum InfrastructureError: VeiraError, Equatable {
    case networkUnavailable
    case timedOut
    case unauthorized
    case forbidden
    case notFound
    case decodingFailed
    case encodingFailed
    case server(statusCode: Int)
    case underlying(message: String)

    public var userFacingMessage: String {
        switch self {
        case .networkUnavailable:
            "Please check your connection and try again."
        case .timedOut:
            "That took longer than expected. Please try again."
        case .unauthorized, .forbidden:
            "You don’t have access to this right now."
        case .notFound:
            "We couldn’t find what you were looking for."
        case .decodingFailed, .encodingFailed:
            "Something went wrong loading your data."
        case .server:
            "Our servers are having trouble. Please try again shortly."
        case .underlying:
            "Something went wrong. Please try again."
        }
    }

    public var isRetryable: Bool {
        switch self {
        case .networkUnavailable, .timedOut, .server:
            true
        case .unauthorized, .forbidden, .notFound, .decodingFailed, .encodingFailed, .underlying:
            false
        }
    }
}
