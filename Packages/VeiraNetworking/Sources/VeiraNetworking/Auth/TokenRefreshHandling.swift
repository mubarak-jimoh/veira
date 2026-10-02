import Foundation

/// Performs a single auth-token refresh when the API returns 401.
///
/// Implementations must use a dedicated, non-authenticated transport so refresh
/// cannot recurse into the same interceptor pipeline.
public protocol TokenRefreshHandling: Sendable {
    /// Returns `true` when credentials were refreshed and the original request may retry once.
    func refreshCredentials() async throws -> Bool
}
