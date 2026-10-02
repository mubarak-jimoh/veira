import Foundation
import VeiraCore

/// A daily skincare routine with ordered steps.
public struct SkinRoutine: Sendable, Equatable, Identifiable, Codable {
    public let id: RoutineID
    public let title: String
    public let period: RoutinePeriod
    public let steps: [RoutineStep]
    public let estimatedMinutes: Int

    public init(
        id: RoutineID = RoutineID(),
        title: String,
        period: RoutinePeriod,
        steps: [RoutineStep],
        estimatedMinutes: Int
    ) {
        self.id = id
        self.title = title
        self.period = period
        self.steps = steps
        self.estimatedMinutes = estimatedMinutes
    }

    public var completedCount: Int {
        steps.filter(\.isCompleted).count
    }

    public var completionProgress: Double {
        guard !steps.isEmpty else { return 0 }
        return Double(completedCount) / Double(steps.count)
    }
}

public enum RoutinePeriod: String, Sendable, Codable, CaseIterable {
    case morning
    case evening

    public var title: String {
        switch self {
        case .morning: "Morning"
        case .evening: "Evening"
        }
    }
}

public struct RoutineStep: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let title: String
    public let detail: String
    public let durationSeconds: Int
    public var isCompleted: Bool
    public let symbolName: String

    public init(
        id: UUID = UUID(),
        title: String,
        detail: String,
        durationSeconds: Int,
        isCompleted: Bool = false,
        symbolName: String
    ) {
        self.id = id
        self.title = title
        self.detail = detail
        self.durationSeconds = durationSeconds
        self.isCompleted = isCompleted
        self.symbolName = symbolName
    }
}
