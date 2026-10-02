import SwiftUI

/// Typography scale for Veira.
///
/// Display uses New York (system serif) for calm editorial presence.
/// Body and UI chrome use SF Pro for clarity and Dynamic Type fidelity.
///
/// All public font accessors scale with Dynamic Type.
public struct VeiraTypography: Sendable, Equatable {

    public enum Style: String, Sendable, CaseIterable {
        case displayLarge
        case displayMedium
        case titleLarge
        case titleMedium
        case titleSmall
        case bodyLarge
        case bodyMedium
        case bodySmall
        case labelLarge
        case labelMedium
        case labelSmall
        case caption
        case overline
    }

    public init() {}

    public func relativeTextStyle(for style: Style) -> Font.TextStyle {
        switch style {
        case .displayLarge: .largeTitle
        case .displayMedium: .title
        case .titleLarge: .title2
        case .titleMedium: .title3
        case .titleSmall: .headline
        case .bodyLarge, .labelLarge: .body
        case .bodyMedium, .labelMedium: .callout
        case .bodySmall, .labelSmall: .subheadline
        case .caption: .caption
        case .overline: .caption2
        }
    }

    /// Font that scales with Dynamic Type — the only font API for product UI.
    public func font(for style: Style) -> Font {
        .system(
            relativeTextStyle(for: style),
            design: style.isSerif ? .serif : .default,
            weight: style.weight
        )
    }

    /// Alias retained for call-site clarity.
    public func scaledFont(for style: Style) -> Font {
        font(for: style)
    }
}

private extension VeiraTypography.Style {
    var isSerif: Bool {
        switch self {
        case .displayLarge, .displayMedium: true
        default: false
        }
    }

    var weight: Font.Weight {
        switch self {
        case .displayLarge, .displayMedium,
             .titleLarge, .titleMedium, .titleSmall,
             .labelLarge, .labelMedium, .labelSmall, .overline:
            .semibold
        case .bodyLarge, .bodyMedium, .bodySmall, .caption:
            .regular
        }
    }
}

public extension View {
    func veiraFont(_ style: VeiraTypography.Style, typography: VeiraTypography = VeiraTypography()) -> some View {
        font(typography.scaledFont(for: style))
    }
}
