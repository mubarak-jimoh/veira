import Foundation

/// A weekly progress point used by the Progress screen.
public struct ProgressSnapshot: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let weekLabel: String
    public let score: Int
    public let note: String
    public let capturedAt: Date

    public init(
        id: UUID = UUID(),
        weekLabel: String,
        score: Int,
        note: String,
        capturedAt: Date
    ) {
        self.id = id
        self.weekLabel = weekLabel
        self.score = min(max(score, 0), 100)
        self.note = note
        self.capturedAt = capturedAt
    }
}

/// Lightweight profile shown across home and settings.
public struct UserProfile: Sendable, Equatable, Codable {
    public let displayName: String
    public let email: String
    public let skinGoal: String
    public let memberSince: Date

    public init(
        displayName: String,
        email: String,
        skinGoal: String,
        memberSince: Date
    ) {
        self.displayName = displayName
        self.email = email
        self.skinGoal = skinGoal
        self.memberSince = memberSince
    }

    public var firstName: String {
        displayName.split(separator: " ").first.map(String.init) ?? displayName
    }
}
