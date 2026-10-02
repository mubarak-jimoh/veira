import Foundation

/// Session identity for an authenticated Veira user.
///
/// Feature-specific models (skin scores, scans, etc.) will live alongside this
/// once product features are implemented. This file intentionally stays minimal.
public struct UserSession: Sendable, Equatable, Codable {
    public let userID: UserID
    public let accessToken: String
    public let refreshToken: String
    /// Expiry truncated to millisecond precision so Keychain round-trips stay `Equatable`.
    public let expiresAt: Date

    public init(
        userID: UserID,
        accessToken: String,
        refreshToken: String,
        expiresAt: Date
    ) {
        self.userID = userID
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt.veiraMillisecondPrecision
    }

    public func isExpired(at date: Date = Date()) -> Bool {
        date.veiraMillisecondPrecision >= expiresAt
    }
}

extension Date {
    /// Floors to whole milliseconds — matches `.millisecondsSince1970` JSON coding.
    var veiraMillisecondPrecision: Date {
        Date(timeIntervalSince1970: (timeIntervalSince1970 * 1_000).rounded(.down) / 1_000)
    }
}
