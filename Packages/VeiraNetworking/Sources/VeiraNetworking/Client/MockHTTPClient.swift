import Foundation

/// In-memory HTTP client for unit tests and SwiftUI previews.
public actor MockHTTPClient: HTTPClient {
    public struct Stub: Sendable {
        public let data: Data
        public let statusCode: Int
        public let headers: [String: String]

        public init(data: Data, statusCode: Int = 200, headers: [String: String] = [:]) {
            self.data = data
            self.statusCode = statusCode
            self.headers = headers
        }

        public static func json<T: Encodable>(
            _ value: T,
            statusCode: Int = 200,
            encoder: JSONEncoder = APIJSONCoding.encoder
        ) throws -> Stub {
            Stub(data: try encoder.encode(value), statusCode: statusCode)
        }
    }

    private var stubs: [String: Stub] = [:]
    private(set) public var recordedEndpoints: [Endpoint] = []

    public init() {}

    public func stub(path: String, with stub: Stub) {
        stubs[path] = stub
    }

    public func send(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        recordedEndpoints.append(endpoint)

        guard let stub = stubs[endpoint.path] else {
            throw NetworkError.http(statusCode: 404, data: nil)
        }

        let url = URL(string: "https://mock.veira.app/\(endpoint.path)")!
        let response = HTTPURLResponse(
            url: url,
            statusCode: stub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: stub.headers
        )!

        guard (200...299).contains(stub.statusCode) else {
            if stub.statusCode == 401 {
                throw NetworkError.unauthorized
            }
            throw NetworkError.http(statusCode: stub.statusCode, data: stub.data)
        }

        return (stub.data, response)
    }
}
