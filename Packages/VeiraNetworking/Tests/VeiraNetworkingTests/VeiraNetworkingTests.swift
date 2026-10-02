import XCTest
@testable import VeiraNetworking

final class EndpointTests: XCTestCase {
    func testJSONEncodingSetsContentType() throws {
        struct Body: Encodable { let name: String }
        let endpoint = try Endpoint.json("/users", method: .post, body: Body(name: "Veira"), requiresAuthentication: false)
        XCTAssertEqual(endpoint.method, .post)
        XCTAssertEqual(endpoint.headers["Content-Type"], "application/json")
        XCTAssertNotNil(endpoint.body)
        XCTAssertFalse(endpoint.requiresAuthentication)
    }
}

final class NetworkErrorTests: XCTestCase {
    func testRetryableServerErrors() {
        XCTAssertTrue(NetworkError.http(statusCode: 503, data: nil).isRetryable)
        XCTAssertFalse(NetworkError.http(statusCode: 400, data: nil).isRetryable)
        XCTAssertFalse(NetworkError.unauthorized.isRetryable)
    }
}
