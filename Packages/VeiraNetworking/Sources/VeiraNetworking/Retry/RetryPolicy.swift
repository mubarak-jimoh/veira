import Foundation

/// Exponential backoff policy for retryable transport and server errors.
public struct RetryPolicy: Sendable, Equatable {
    public let maxAttempts: Int
    public let baseDelayNanoseconds: UInt64
    public let maximumDelayNanoseconds: UInt64

    public init(
        maxAttempts: Int = 3,
        baseDelayNanoseconds: UInt64 = 200_000_000,
        maximumDelayNanoseconds: UInt64 = 2_000_000_000
    ) {
        self.maxAttempts = max(1, maxAttempts)
        self.baseDelayNanoseconds = baseDelayNanoseconds
        self.maximumDelayNanoseconds = maximumDelayNanoseconds
    }

    public static let standard = RetryPolicy()
    public static let none = RetryPolicy(maxAttempts: 1, baseDelayNanoseconds: 0)

    public func delayNanoseconds(forAttempt attempt: Int) -> UInt64 {
        guard attempt > 1, baseDelayNanoseconds > 0 else { return 0 }
        let shift = min(attempt - 1, 6)
        let scaled = baseDelayNanoseconds &<< UInt64(shift)
        return min(scaled, maximumDelayNanoseconds)
    }
}
