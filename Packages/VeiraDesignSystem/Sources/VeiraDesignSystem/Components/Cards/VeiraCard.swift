import SwiftUI

public enum VeiraCardElevation: Sendable {
    case flat
    case soft
    case medium
}

/// Surface container for interactive groupings — used sparingly.
/// Prefer open layouts; use cards only when they clarify an interaction.
public struct VeiraCard<Content: View>: View {
    private let elevation: VeiraCardElevation
    private let padding: CGFloat
    private let content: Content

    @Environment(\.veiraTheme) private var theme

    public init(
        elevation: VeiraCardElevation = .soft,
        padding: CGFloat = VeiraLayout.cardPadding,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.padding = padding
        self.content = content()
    }

    public var body: some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            }
            .veiraShadow(shadow)
    }

    private var shadow: VeiraShadow {
        switch elevation {
        case .flat: theme.shadows.none
        case .soft: theme.shadows.soft
        case .medium: theme.shadows.medium
        }
    }
}

/// Tappable card variant with press feedback.
public struct VeiraTappableCard<Content: View>: View {
    private let elevation: VeiraCardElevation
    private let action: () -> Void
    private let content: Content

    public init(
        elevation: VeiraCardElevation = .soft,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.elevation = elevation
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Button(action: action) {
            VeiraCard(elevation: elevation) { content }
        }
        .buttonStyle(VeiraPressableButtonStyle())
    }
}
