import SwiftUI

/// Elevation / shadow tokens.
public struct VeiraShadow: Sendable, Equatable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public struct VeiraShadows: Sendable, Equatable {
    public let none: VeiraShadow
    public let soft: VeiraShadow
    public let medium: VeiraShadow
    public let pronounced: VeiraShadow

    public init(none: VeiraShadow, soft: VeiraShadow, medium: VeiraShadow, pronounced: VeiraShadow) {
        self.none = none
        self.soft = soft
        self.medium = medium
        self.pronounced = pronounced
    }
}

public extension VeiraShadows {
    static let light = VeiraShadows(
        none: VeiraShadow(color: .clear, radius: 0, y: 0),
        soft: VeiraShadow(color: Color(hex: 0x14171A).opacity(0.06), radius: 12, y: 4),
        medium: VeiraShadow(color: Color(hex: 0x14171A).opacity(0.10), radius: 20, y: 8),
        pronounced: VeiraShadow(color: Color(hex: 0x14171A).opacity(0.16), radius: 32, y: 12)
    )

    static let dark = VeiraShadows(
        none: VeiraShadow(color: .clear, radius: 0, y: 0),
        soft: VeiraShadow(color: Color.black.opacity(0.28), radius: 12, y: 4),
        medium: VeiraShadow(color: Color.black.opacity(0.40), radius: 20, y: 8),
        pronounced: VeiraShadow(color: Color.black.opacity(0.55), radius: 32, y: 12)
    )
}

public extension View {
    func veiraShadow(_ shadow: VeiraShadow) -> some View {
        self.shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}
