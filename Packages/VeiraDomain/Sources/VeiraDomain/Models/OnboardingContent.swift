import Foundation

/// A single onboarding page in the welcome funnel.
public struct OnboardingPage: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let title: String
    public let message: String
    public let symbolName: String

    public init(
        id: UUID = UUID(),
        title: String,
        message: String,
        symbolName: String
    ) {
        self.id = id
        self.title = title
        self.message = message
        self.symbolName = symbolName
    }
}

/// Permission request presented before entering the main app.
public struct PermissionItem: Sendable, Equatable, Identifiable {
    public let id: UUID
    public let title: String
    public let detail: String
    public let symbolName: String
    public let kind: PermissionKind

    public init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        symbolName: String,
        kind: PermissionKind
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.symbolName = symbolName
        self.kind = kind
    }
}

public enum PermissionKind: String, Sendable, Codable, CaseIterable {
    case camera
    case photos
    case notifications
}
