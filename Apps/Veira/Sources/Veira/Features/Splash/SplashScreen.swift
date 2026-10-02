import SwiftUI
import VeiraDesignSystem

/// Launch / bootstrap surface shown while the composition root starts services.
struct SplashScreen: View {
    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            VeiraAtmosphere()

            VStack(spacing: VeiraSpacing.lg.value) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(theme.colors.accentMuted)
                        .frame(width: 96, height: 96)
                        .scaleEffect(appeared ? 1 : 0.86)

                    Text("V")
                        .font(.system(.largeTitle, design: .serif).weight(.semibold))
                        .foregroundStyle(theme.colors.accent)
                }
                .accessibilityHidden(true)

                Text("Veira")
                    .veiraFont(.displayLarge)
                    .foregroundStyle(theme.colors.textPrimary)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .accessibilityAddTraits(.isHeader)

                Text("Skin intelligence, calmly.")
                    .veiraFont(.bodyLarge)
                    .foregroundStyle(theme.colors.textSecondary)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                VeiraLoadingView(message: nil)
                    .frame(height: 48)
                    .opacity(appeared ? 1 : 0)

                Spacer(minLength: VeiraSpacing.huge.value)
            }
            .veiraScreenPadding()
        }
        .accessibilityLabel("Veira is starting")
        .onAppear {
            withAnimation(reduceMotion ? .easeOut(duration: 0.01) : VeiraMotion.gentleSpring) {
                appeared = true
            }
        }
    }
}

/// Backwards-compatible alias used by older references.
typealias LaunchView = SplashScreen
