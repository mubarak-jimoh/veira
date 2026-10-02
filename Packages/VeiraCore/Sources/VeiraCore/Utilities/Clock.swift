import Foundation

/// Clock abstraction for testable time-dependent logic.
public protocol ClockProviding: Sendable {
    func now() -> Date
}

public struct SystemClock: ClockProviding {
    public init() {}

    public func now() -> Date { Date() }
}

public struct FixedClock: ClockProviding {
    private let date: Date

    public init(_ date: Date) {
        self.date = date
    }

    public func now() -> Date { date }
}
