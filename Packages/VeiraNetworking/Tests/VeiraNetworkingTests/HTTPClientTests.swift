import XCTest
import VeiraCore
@testable import VeiraNetworking

/// Answers `URLSession` requests from a queue of canned responses, so the real
/// client can be exercised end to end without touching the network.
final class StubURLProtocol: URLProtocol, @unchecked Sendable {
    struct Response {
        let status: Int
        let body: Data

        init(_ status: Int, json: String = "{}") {
            self.status = status
            self.body = Data(json.utf8)
        }
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var queue: [Response] = []
    nonisolated(unsafe) private static var requests: [URLRequest] = []

    static func reset(_ responses: [Response]) {
        lock.withLock {
            queue = responses
            requests = []
        }
    }

    static var recorded: [URLRequest] {
        lock.withLock { requests }
    }

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let next: Response? = Self.lock.withLock {
            Self.requests.append(request)
            return Self.queue.isEmpty ? nil : Self.queue.removeFirst()
        }

        // An empty queue behaves like a dropped connection.
        guard
            let next,
            let url = request.url,
            let response = HTTPURLResponse(
                url: url,
                statusCode: next.status,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )
        else {
            client?.urlProtocol(self, didFailWithError: URLError(.notConnectedToInternet))
            return
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: next.body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}

private actor CountingRefresher: TokenRefreshHandling {
    private let succeeds: Bool
    private(set) var calls = 0

    init(succeeds: Bool) {
        self.succeeds = succeeds
    }

    func refreshCredentials() async throws -> Bool {
        calls += 1
        return succeeds
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    private func makeClient(
        refresher: (any TokenRefreshHandling)? = nil,
        interceptors: [any RequestInterceptor] = []
    ) -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]

        return URLSessionHTTPClient(
            baseURL: URL(string: "https://api.example.com/v1")!,
            session: URLSession(configuration: configuration),
            requestInterceptors: interceptors,
            // No delay between attempts keeps the suite fast.
            retryPolicy: RetryPolicy(maxAttempts: 3, baseDelayNanoseconds: 0),
            tokenRefresher: refresher,
            logger: NoOpLogger()
        )
    }

    private func assertThrows(
        _ expected: NetworkError,
        file: StaticString = #filePath,
        line: UInt = #line,
        _ work: () async throws -> Void
    ) async {
        do {
            try await work()
            XCTFail("Expected \(expected) to be thrown", file: file, line: line)
        } catch let error as NetworkError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }

    // MARK: - Requests

    func testBuildsURLFromBasePathAndQuery() async throws {
        StubURLProtocol.reset([.init(200)])
        let endpoint = Endpoint.get("/scores", queryItems: [URLQueryItem(name: "limit", value: "5")])

        _ = try await makeClient().send(endpoint)

        XCTAssertEqual(
            StubURLProtocol.recorded.first?.url?.absoluteString,
            "https://api.example.com/v1/scores?limit=5"
        )
        XCTAssertEqual(StubURLProtocol.recorded.first?.httpMethod, "GET")
    }

    func testInterceptorsRunBeforeTheRequestIsSent() async throws {
        StubURLProtocol.reset([.init(200)])
        let client = makeClient(interceptors: [
            AuthenticationInterceptor { "token-123" },
            RequestIDInterceptor()
        ])

        _ = try await client.send(.get("/me"))

        let request = try XCTUnwrap(StubURLProtocol.recorded.first)
        XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer token-123")
        XCTAssertNotNil(request.value(forHTTPHeaderField: "X-Request-ID"))
    }

    func testDecodesSnakeCaseJSONIntoCamelCaseProperties() async throws {
        struct Payload: Decodable, Equatable { let skinScore: Int }
        StubURLProtocol.reset([.init(200, json: #"{"skin_score": 82}"#)])

        let payload: Payload = try await makeClient().send(.get("/scores/today"))

        XCTAssertEqual(payload, Payload(skinScore: 82))
    }

    func testMalformedBodyBecomesADecodingError() async {
        struct Payload: Decodable { let skinScore: Int }
        StubURLProtocol.reset([.init(200, json: "not json")])

        do {
            let _: Payload = try await makeClient().send(.get("/scores/today"))
            XCTFail("Expected a decoding error")
        } catch let NetworkError.decoding(message) {
            XCTAssertFalse(message.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Retries

    func testRetriesAServerErrorAndThenSucceeds() async throws {
        StubURLProtocol.reset([.init(503), .init(200, json: #"{"ok": true}"#)])

        let (data, response) = try await makeClient().send(.get("/scores"))

        XCTAssertEqual(response.statusCode, 200)
        XCTAssertEqual(String(decoding: data, as: UTF8.self), #"{"ok": true}"#)
        XCTAssertEqual(StubURLProtocol.recorded.count, 2)
    }

    func testGivesUpAfterTheMaximumNumberOfAttempts() async {
        StubURLProtocol.reset([.init(500), .init(500), .init(500), .init(200)])
        let client = makeClient()

        await assertThrows(.http(statusCode: 500, data: Data("{}".utf8))) {
            _ = try await client.send(.get("/scores"))
        }
        XCTAssertEqual(StubURLProtocol.recorded.count, 3)
    }

    func testDoesNotRetryAClientError() async {
        StubURLProtocol.reset([.init(400), .init(200)])
        let client = makeClient()

        await assertThrows(.http(statusCode: 400, data: Data("{}".utf8))) {
            _ = try await client.send(.get("/scores"))
        }
        XCTAssertEqual(StubURLProtocol.recorded.count, 1)
    }

    func testRetriesWhenTheConnectionDrops() async {
        StubURLProtocol.reset([])

        do {
            _ = try await makeClient().send(.get("/scores"))
            XCTFail("Expected a transport error")
        } catch NetworkError.transport {
            XCTAssertEqual(StubURLProtocol.recorded.count, 3)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Token refresh

    func testAnExpiredTokenIsRefreshedAndTheRequestRepeatedOnce() async throws {
        StubURLProtocol.reset([.init(401), .init(200)])
        let refresher = CountingRefresher(succeeds: true)

        let (_, response) = try await makeClient(refresher: refresher).send(.get("/me"))

        XCTAssertEqual(response.statusCode, 200)
        let refreshCalls = await refresher.calls
        XCTAssertEqual(refreshCalls, 1)
        XCTAssertEqual(StubURLProtocol.recorded.count, 2)
    }

    func testAFailedRefreshSurfacesUnauthorized() async {
        StubURLProtocol.reset([.init(401), .init(200)])
        let client = makeClient(refresher: CountingRefresher(succeeds: false))

        await assertThrows(.unauthorized) {
            _ = try await client.send(.get("/me"))
        }
        XCTAssertEqual(StubURLProtocol.recorded.count, 1)
    }

    func testASecondUnauthorizedDoesNotCauseARefreshLoop() async {
        StubURLProtocol.reset([.init(401), .init(401), .init(200)])
        let refresher = CountingRefresher(succeeds: true)
        let client = makeClient(refresher: refresher)

        await assertThrows(.unauthorized) {
            _ = try await client.send(.get("/me"))
        }
        let refreshCalls = await refresher.calls
        XCTAssertEqual(refreshCalls, 1)
        XCTAssertEqual(StubURLProtocol.recorded.count, 2)
    }

    func testAPublicEndpointNeverTriggersARefresh() async {
        StubURLProtocol.reset([.init(401)])
        let refresher = CountingRefresher(succeeds: true)
        let client = makeClient(refresher: refresher)

        await assertThrows(.unauthorized) {
            _ = try await client.send(.get("/status", requiresAuthentication: false))
        }
        let refreshCalls = await refresher.calls
        XCTAssertEqual(refreshCalls, 0)
    }
}
