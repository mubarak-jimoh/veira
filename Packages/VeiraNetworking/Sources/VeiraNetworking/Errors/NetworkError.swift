import Foundation
import VeiraCore

public enum NetworkError: VeiraError, Equatable {
    case invalidURL
    case invalidResponse
    case transport(message: String)
    case http(statusCode: Int, data: Data?)
    case decoding(message: String)
    case cancelled
    case unauthorized

    public var userFacingMessage: String {
        switch self {
        case .invalidURL, .invalidResponse, .decoding:
            "Something went wrong loading your data."
        case .transport:
            "Please check your connection and try again."
        case .http(let statusCode, _) where (500...599).contains(statusCode):
            "Our servers are having trouble. Please try again shortly."
        case .http(404, _):
            "We couldn’t find what you were looking for."
        case .http:
            "Something went wrong. Please try again."
        case .cancelled:
            "The request was cancelled."
        case .unauthorized:
            "Please sign in again to continue."
        }
    }

    public var isRetryable: Bool {
        switch self {
        case .transport:
            true
        case .http(let code, _) where (500...599).contains(code) || code == 408 || code == 429:
            true
        case .invalidURL, .invalidResponse, .decoding, .cancelled, .unauthorized, .http:
            false
        }
    }

    public var asInfrastructureError: InfrastructureError {
        switch self {
        case .transport:
            .networkUnavailable
        case .http(401, _):
            .unauthorized
        case .http(403, _):
            .forbidden
        case .http(404, _):
            .notFound
        case .http(let code, _):
            .server(statusCode: code)
        case .decoding:
            .decodingFailed
        case .unauthorized:
            .unauthorized
        case .invalidURL, .invalidResponse, .cancelled:
            .underlying(message: userFacingMessage)
        }
    }
}
