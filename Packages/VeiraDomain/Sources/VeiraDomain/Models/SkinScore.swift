import Foundation

/// Overall skin health score for a given day.
public struct SkinScore: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let value: Int
    public let capturedAt: Date
    public let summary: String
    public let metrics: [SkinMetric]

    public init(
        id: UUID = UUID(),
        value: Int,
        capturedAt: Date,
        summary: String,
        metrics: [SkinMetric]
    ) {
        self.id = id
        self.value = min(max(value, 0), 100)
        self.capturedAt = capturedAt
        self.summary = summary
        self.metrics = metrics
    }

    public var normalizedProgress: Double {
        Double(value) / 100.0
    }

    public var band: ScoreBand {
        switch value {
        case 85...: .excellent
        case 70..<85: .good
        case 55..<70: .fair
        default: .needsAttention
        }
    }
}

public enum ScoreBand: String, Sendable, Codable {
    case excellent
    case good
    case fair
    case needsAttention

    public var title: String {
        switch self {
        case .excellent: "Excellent"
        case .good: "Good"
        case .fair: "Fair"
        case .needsAttention: "Needs care"
        }
    }
}

/// Individual skin metric contributing to the overall score.
public struct SkinMetric: Sendable, Equatable, Identifiable, Codable {
    public let id: UUID
    public let name: String
    public let value: Int
    public let insight: String
    public let symbolName: String

    public init(
        id: UUID = UUID(),
        name: String,
        value: Int,
        insight: String,
        symbolName: String
    ) {
        self.id = id
        self.name = name
        self.value = min(max(value, 0), 100)
        self.insight = insight
        self.symbolName = symbolName
    }

    public var normalizedProgress: Double {
        Double(value) / 100.0
    }
}
