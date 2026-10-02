import CoreGraphics

/// Spacing scale — 4pt base grid.
public enum VeiraSpacing: CGFloat, Sendable, CaseIterable {
    case xxxs = 2
    case xxs = 4
    case xs = 8
    case sm = 12
    case md = 16
    case lg = 24
    case xl = 32
    case xxl = 40
    case xxxl = 48
    case huge = 64
    case massive = 80

    public var value: CGFloat { rawValue }
}

/// Layout insets used across screens.
public enum VeiraLayout: Sendable {
    public static let screenHorizontal: CGFloat = VeiraSpacing.lg.value
    public static let screenTop: CGFloat = VeiraSpacing.md.value
    public static let sectionSpacing: CGFloat = VeiraSpacing.xl.value
    public static let cardPadding: CGFloat = VeiraSpacing.md.value
    public static let minTapTarget: CGFloat = 44
}
