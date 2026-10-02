import XCTest
@testable import VeiraNetworking

final class RetryPolicyTests: XCTestCase {
    func testTheFirstAttemptIsNeverDelayed() {
        XCTAssertEqual(RetryPolicy.standard.delayNanoseconds(forAttempt: 1), 0)
    }

    func testTheDelayDoublesWithEachAttempt() {
        let policy = RetryPolicy(maxAttempts: 5, baseDelayNanoseconds: 100, maximumDelayNanoseconds: 10_000)
        XCTAssertEqual(policy.delayNanoseconds(forAttempt: 2), 200)
        XCTAssertEqual(policy.delayNanoseconds(forAttempt: 3), 400)
        XCTAssertEqual(policy.delayNanoseconds(forAttempt: 4), 800)
    }

    func testTheDelayIsCappedAtTheMaximum() {
        let policy = RetryPolicy(maxAttempts: 10, baseDelayNanoseconds: 100, maximumDelayNanoseconds: 500)
        XCTAssertEqual(policy.delayNanoseconds(forAttempt: 9), 500)
    }

    func testThereIsAlwaysAtLeastOneAttempt() {
        XCTAssertEqual(RetryPolicy(maxAttempts: 0).maxAttempts, 1)
        XCTAssertEqual(RetryPolicy(maxAttempts: -3).maxAttempts, 1)
        XCTAssertEqual(RetryPolicy.none.maxAttempts, 1)
    }
}

final class NetworkErrorClassificationTests: XCTestCase {
    func testTemporaryFailuresAreRetryable() {
        for code in [408, 429, 500, 502, 503, 599] {
            XCTAssertTrue(NetworkError.http(statusCode: code, data: nil).isRetryable, "\(code)")
        }
        XCTAssertTrue(NetworkError.transport(message: "offline").isRetryable)
    }

    func testPermanentFailuresAreNotRetryable() {
        for code in [400, 403, 404, 422] {
            XCTAssertFalse(NetworkError.http(statusCode: code, data: nil).isRetryable, "\(code)")
        }
        XCTAssertFalse(NetworkError.cancelled.isRetryable)
        XCTAssertFalse(NetworkError.decoding(message: "bad").isRetryable)
        XCTAssertFalse(NetworkError.invalidURL.isRetryable)
    }

    func testUserFacingMessagesNeverLeakTechnicalDetail() {
        let errors: [NetworkError] = [
            .invalidURL,
            .transport(message: "NSURLErrorDomain -1009"),
            .http(statusCode: 500, data: nil),
            .http(statusCode: 404, data: nil),
            .decoding(message: "keyNotFound(CodingKeys)"),
            .unauthorized
        ]
        for error in errors {
            let message = error.userFacingMessage
            XCTAssertFalse(message.isEmpty)
            XCTAssertFalse(message.contains("NSURLErrorDomain"))
            XCTAssertFalse(message.contains("CodingKeys"))
            XCTAssertFalse(message.contains("500"))
        }
    }
}

final class InterceptorTests: XCTestCase {
    private let request = URLRequest(url: URL(string: "https://api.example.com/v1/me")!)

    func testAuthenticationAddsABearerToken() async throws {
        let interceptor = AuthenticationInterceptor { "abc" }
        let result = try await interceptor.intercept(request, endpoint: .get("/me"))
        XCTAssertEqual(result.value(forHTTPHeaderField: "Authorization"), "Bearer abc")
    }

    func testAuthenticationLeavesPublicEndpointsAlone() async throws {
        let interceptor = AuthenticationInterceptor { "abc" }
        let endpoint = Endpoint.get("/status", requiresAuthentication: false)
        let result = try await interceptor.intercept(request, endpoint: endpoint)
        XCTAssertNil(result.value(forHTTPHeaderField: "Authorization"))
    }

    func testAMissingTokenStopsTheRequest() async {
        let interceptor = AuthenticationInterceptor { nil }
        do {
            _ = try await interceptor.intercept(request, endpoint: .get("/me"))
            XCTFail("Expected unauthorized")
        } catch {
            XCTAssertEqual(error as? NetworkError, .unauthorized)
        }
    }

    func testRequestIDIsAddedButNeverOverwritten() async throws {
        let interceptor = RequestIDInterceptor()

        let generated = try await interceptor.intercept(request, endpoint: .get("/me"))
        XCTAssertEqual(generated.value(forHTTPHeaderField: "X-Request-ID")?.count, 36)

        var tagged = request
        tagged.setValue("trace-1", forHTTPHeaderField: "X-Request-ID")
        let kept = try await interceptor.intercept(tagged, endpoint: .get("/me"))
        XCTAssertEqual(kept.value(forHTTPHeaderField: "X-Request-ID"), "trace-1")
    }

    func testDefaultHeadersDescribeTheApp() async throws {
        let interceptor = DefaultHeadersInterceptor(
            appVersion: "1.2.0",
            buildNumber: "42",
            bundleIdentifier: "com.veira.app"
        )
        let result = try await interceptor.intercept(request, endpoint: .get("/me"))
        XCTAssertEqual(result.value(forHTTPHeaderField: "User-Agent"), "Veira/1.2.0 (com.veira.app; build:42)")
        XCTAssertEqual(result.value(forHTTPHeaderField: "X-Veira-App-Version"), "1.2.0")
        XCTAssertEqual(result.value(forHTTPHeaderField: "Accept"), "application/json")
    }
}

final class MockHTTPClientTests: XCTestCase {
    func testReturnsTheStubAndRecordsTheCall() async throws {
        struct Profile: Codable, Equatable { let displayName: String }
        let client = MockHTTPClient()
        await client.stub(path: "/me", with: try .json(Profile(displayName: "Ada")))

        let profile: Profile = try await client.send(.get("/me"))

        XCTAssertEqual(profile, Profile(displayName: "Ada"))
        let recorded = await client.recordedEndpoints
        XCTAssertEqual(recorded.map(\.path), ["/me"])
    }

    func testAnUnstubbedPathBehavesLikeNotFound() async {
        let client = MockHTTPClient()
        do {
            _ = try await client.send(.get("/missing"))
            XCTFail("Expected a 404")
        } catch {
            XCTAssertEqual(error as? NetworkError, .http(statusCode: 404, data: nil))
        }
    }
}
