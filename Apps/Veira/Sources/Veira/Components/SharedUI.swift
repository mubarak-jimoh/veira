import SwiftUI
import VeiraDesignSystem

/// Soft ambient backdrop used across premium surfaces.
struct VeiraAtmosphere: View {
    @Environment(\.veiraTheme) private var theme

    var body: some View {
        ZStack {
            theme.colors.background

            RadialGradient(
                colors: [
                    theme.colors.accentMuted.opacity(0.55),
                    theme.colors.background.opacity(0)
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )

            RadialGradient(
                colors: [
                    theme.colors.backgroundSecondary.opacity(0.7),
                    theme.colors.background.opacity(0)
                ],
                center: .bottomLeading,
                startRadius: 10,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
        .veiraDecorative()
    }
}

/// Small overline label used above section titles.
struct VeiraOverline: View {
    let text: String
    @Environment(\.veiraTheme) private var theme

    var body: some View {
        Text(text.uppercased())
            .veiraFont(.overline)
            .tracking(1.2)
            .foregroundStyle(theme.colors.textTertiary)
    }
}

/// Circular symbol badge for feature lists.
struct VeiraSymbolBadge: View {
    let systemName: String
    var size: CGFloat = 52

    @Environment(\.veiraTheme) private var theme

    var body: some View {
        ZStack {
            Circle()
                .fill(theme.colors.accentMuted)
                .frame(width: size, height: size)

            Image(systemName: systemName)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(theme.colors.accent)
        }
        .accessibilityHidden(true)
    }
}

/// Section title + optional supporting line.
struct VeiraSectionHeader: View {
    let title: String
    var subtitle: String? = nil

    @Environment(\.veiraTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
            Text(title)
                .veiraFont(.titleSmall)
                .foregroundStyle(theme.colors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .veiraFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
