import SwiftUI

/// Semantic colour tokens for Veira.
///
/// Palette intent: cool pearl surfaces, deep charcoal ink, muted sage accent.
/// Deliberately avoids purple-gradient AI tropes and warm cream/terracotta clichés.
public struct VeiraColors: Sendable, Equatable {
    public let background: Color
    public let backgroundSecondary: Color
    public let surface: Color
    public let surfaceElevated: Color
    public let border: Color
    public let borderSubtle: Color

    public let textPrimary: Color
    public let textSecondary: Color
    public let textTertiary: Color
    public let textInverse: Color

    public let accent: Color
    public let accentMuted: Color
    public let accentContrast: Color

    public let success: Color
    public let warning: Color
    public let danger: Color
    public let info: Color

    public let scoreExcellent: Color
    public let scoreGood: Color
    public let scoreFair: Color
    public let scorePoor: Color

    public let overlay: Color
    public let shimmer: Color

    public init(
        background: Color,
        backgroundSecondary: Color,
        surface: Color,
        surfaceElevated: Color,
        border: Color,
        borderSubtle: Color,
        textPrimary: Color,
        textSecondary: Color,
        textTertiary: Color,
        textInverse: Color,
        accent: Color,
        accentMuted: Color,
        accentContrast: Color,
        success: Color,
        warning: Color,
        danger: Color,
        info: Color,
        scoreExcellent: Color,
        scoreGood: Color,
        scoreFair: Color,
        scorePoor: Color,
        overlay: Color,
        shimmer: Color
    ) {
        self.background = background
        self.backgroundSecondary = backgroundSecondary
        self.surface = surface
        self.surfaceElevated = surfaceElevated
        self.border = border
        self.borderSubtle = borderSubtle
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
        self.textInverse = textInverse
        self.accent = accent
        self.accentMuted = accentMuted
        self.accentContrast = accentContrast
        self.success = success
        self.warning = warning
        self.danger = danger
        self.info = info
        self.scoreExcellent = scoreExcellent
        self.scoreGood = scoreGood
        self.scoreFair = scoreFair
        self.scorePoor = scorePoor
        self.overlay = overlay
        self.shimmer = shimmer
    }
}

public extension VeiraColors {
    /// Light appearance — cool pearl, soft sage.
    static let light = VeiraColors(
        background: Color(hex: 0xF3F4F6),
        backgroundSecondary: Color(hex: 0xE8EAED),
        surface: Color(hex: 0xFFFFFF),
        surfaceElevated: Color(hex: 0xFFFFFF),
        border: Color(hex: 0xD5D8DD),
        borderSubtle: Color(hex: 0xE8EAED),
        textPrimary: Color(hex: 0x14171A),
        textSecondary: Color(hex: 0x5C6570),
        textTertiary: Color(hex: 0x8B939E),
        textInverse: Color(hex: 0xFFFFFF),
        accent: Color(hex: 0x3A6B5C),
        accentMuted: Color(hex: 0xD7E5DF),
        accentContrast: Color(hex: 0xFFFFFF),
        success: Color(hex: 0x2F6B4F),
        warning: Color(hex: 0xA67C2E),
        danger: Color(hex: 0xB42318),
        info: Color(hex: 0x2F5B8A),
        scoreExcellent: Color(hex: 0x2F6B4F),
        scoreGood: Color(hex: 0x3A6B5C),
        scoreFair: Color(hex: 0xA67C2E),
        scorePoor: Color(hex: 0xB42318),
        overlay: Color(hex: 0x14171A).opacity(0.48),
        shimmer: Color(hex: 0xE8EAED)
    )

    /// Dark appearance — warm charcoal, luminous sage.
    static let dark = VeiraColors(
        background: Color(hex: 0x0F1113),
        backgroundSecondary: Color(hex: 0x171A1D),
        surface: Color(hex: 0x1C2024),
        surfaceElevated: Color(hex: 0x252A2F),
        border: Color(hex: 0x343A41),
        borderSubtle: Color(hex: 0x2A2F35),
        textPrimary: Color(hex: 0xF3F4F6),
        textSecondary: Color(hex: 0xA7AFB8),
        textTertiary: Color(hex: 0x6E7782),
        textInverse: Color(hex: 0x14171A),
        accent: Color(hex: 0x7FB39A),
        accentMuted: Color(hex: 0x24352E),
        accentContrast: Color(hex: 0x0F1113),
        success: Color(hex: 0x6FBF93),
        warning: Color(hex: 0xE0B35A),
        danger: Color(hex: 0xF07070),
        info: Color(hex: 0x7BA7D4),
        scoreExcellent: Color(hex: 0x6FBF93),
        scoreGood: Color(hex: 0x7FB39A),
        scoreFair: Color(hex: 0xE0B35A),
        scorePoor: Color(hex: 0xF07070),
        overlay: Color(hex: 0x000000).opacity(0.64),
        shimmer: Color(hex: 0x2A2F35)
    )
}

extension Color {
    /// Module-internal hex helper — tokens own colour construction.
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
