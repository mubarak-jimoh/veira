import Foundation
import VeiraCore

public protocol HTTPClient: Sendable {
    func send(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse)
    func send<Response: Decodable>(
        _ endpoint: Endpoint,
        decodeAs: Response.Type,
        decoder: JSONDecoder
    ) async throws -> Response
}

public extension HTTPClient {
    func send<Response: Decodable>(
        _ endpoint: Endpoint,
        decodeAs: Response.Type = Response.self,
        decoder: JSONDecoder = APIJSONCoding.decoder
    ) async throws -> Response {
        let (data, _) = try await send(endpoint)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw NetworkError.decoding(message: String(describing: error))
        }
    }
}

/// Production URLSession-backed HTTP client with retry and optional token refresh.
public actor URLSessionHTTPClient: HTTPClient {
    private let baseURL: URL
    private let session: URLSession
    private let requestInterceptors: [any RequestInterceptor]
    private let responseInterceptors: [any ResponseInterceptor]
    private let retryPolicy: RetryPolicy
    private let tokenRefresher: (any TokenRefreshHandling)?
    private let logger: any Logging

    public init(
        baseURL: URL,
        session: URLSession = .shared,
        requestInterceptors: [any RequestInterceptor] = [],
        responseInterceptors: [any ResponseInterceptor] = [],
        retryPolicy: RetryPolicy = .standard,
        tokenRefresher: (any TokenRefreshHandling)? = nil,
        logger: any Logging
    ) {
        self.baseURL = baseURL
        self.session = session
        self.requestInterceptors = requestInterceptors
        self.responseInterceptors = responseInterceptors
        self.retryPolicy = retryPolicy
        self.tokenRefresher = tokenRefresher
        self.logger = logger
    }

    public func send(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        try await send(endpoint, allowUnauthorizedRetry: true)
    }

    private func send(
        _ endpoint: Endpoint,
        allowUnauthorizedRetry: Bool
    ) async throws -> (Data, HTTPURLResponse) {
        var attempt = 0
        var lastError: NetworkError?

        while attempt < retryPolicy.maxAttempts {
            attempt += 1
            let delay = retryPolicy.delayNanoseconds(forAttempt: attempt)
            if delay > 0 {
                try await Task.sleep(nanoseconds: delay)
            }

            do {
                return try await perform(endpoint)
            } catch let error as NetworkError {
                if error == .unauthorized,
                   allowUnauthorizedRetry,
                   endpoint.requiresAuthentication,
                   let refresher = tokenRefresher {
                    let refreshed = try await refresher.refreshCredentials()
                    if refreshed {
                        return try await send(endpoint, allowUnauthorizedRetry: false)
                    }
                    throw NetworkError.unauthorized
                }

                lastError = error
                if error.isRetryable, attempt < retryPolicy.maxAttempts {
                    logger.debug(
                        "Retrying \(endpoint.method.rawValue) \(endpoint.path) (attempt \(attempt + 1))",
                        category: .networking
                    )
                    continue
                }
                throw error
            }
        }

        throw lastError ?? NetworkError.transport(message: "Request failed after retries")
    }

    private func perform(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        let request = try await buildRequest(for: endpoint)
        logger.debug(
            "\(endpoint.method.rawValue) \(request.url?.absoluteString ?? endpoint.path)",
            category: .networking
        )

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }

            for interceptor in responseInterceptors {
                try await interceptor.intercept(response: http, data: data, endpoint: endpoint)
            }

            guard (200...299).contains(http.statusCode) else {
                if http.statusCode == 401 {
                    throw NetworkError.unauthorized
                }
                throw NetworkError.http(statusCode: http.statusCode, data: data)
            }

            return (data, http)
        } catch let error as NetworkError {
            throw error
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.transport(message: error.localizedDescription)
        }
    }

    private func buildRequest(for endpoint: Endpoint) async throws -> URLRequest {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(trimSlash(endpoint.path)),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }

        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }

        guard let url = components.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url, timeoutInterval: endpoint.timeout)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        var intercepted = request
        for interceptor in requestInterceptors {
            intercepted = try await interceptor.intercept(intercepted, endpoint: endpoint)
        }
        return intercepted
    }

    private func trimSlash(_ path: String) -> String {
        if path.hasPrefix("/") {
            return String(path.dropFirst())
        }
        return path
    }
}
