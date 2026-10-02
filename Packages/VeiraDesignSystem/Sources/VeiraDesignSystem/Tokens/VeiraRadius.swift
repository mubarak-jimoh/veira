import CoreGraphics

/// Corner radius tokens.
public enum VeiraRadius: CGFloat, Sendable, CaseIterable {
    case none = 0
    case xs = 6
    case sm = 10
    case md = 14
    case lg = 20
    case xl = 28
    case full = 999

    public var value: CGFloat { rawValue }
}
