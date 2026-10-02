import Foundation
import VeiraCore
import VeiraDomain
import VeiraNetworking

/// Refresh-token exchange using a dedicated unauthenticated HTTP client.
///
/// Kept separate from the main authenticated pipeline so 401 recovery cannot recurse.
public actor SessionTokenRefresher: TokenRefreshHandling {
    private let sessionRepository: any SessionRepository
    private let httpClient: any HTTPClient
    private let logger: any Logging
    private var isRefreshing = false

    public init(
        sessionRepository: any SessionRepository,
        httpClient: any HTTPClient,
        logger: any Logging
    ) {
        self.sessionRepository = sessionRepository
        self.httpClient = httpClient
        self.logger = logger
    }

    public func refreshCredentials() async throws -> Bool {
        if isRefreshing {
            return false
        }

        isRefreshing = true
        defer { isRefreshing = false }

        guard let session = try await sessionRepository.currentSession() else {
            return false
        }

        logger.info("Refreshing auth credentials", category: .networking)

        do {
            let endpoint = try VeiraAPI.Auth.refresh(refreshToken: session.refreshToken)
            let response: AuthRefreshResponse = try await httpClient.send(endpoint)
            let refreshed = UserSession(
                userID: response.userID ?? session.userID,
                accessToken: response.accessToken,
                refreshToken: response.refreshToken ?? session.refreshToken,
                expiresAt: response.expiresAt
            )
            try await sessionRepository.save(refreshed)
            logger.info("Auth credentials refreshed", category: .networking)
            return true
        } catch {
            logger.error("Auth refresh failed: \(error.localizedDescription)", category: .networking)
            try? await sessionRepository.clear()
            throw NetworkError.unauthorized
        }
    }
}

struct AuthRefreshResponse: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String?
    let expiresAt: Date
    let userID: UserID?
}
