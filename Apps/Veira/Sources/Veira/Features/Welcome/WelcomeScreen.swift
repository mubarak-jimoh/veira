import SwiftUI
import VeiraDesignSystem

struct WelcomeScreen: View {
    let onGetStarted: () -> Void
    let onSignIn: () -> Void

    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        ZStack {
            VeiraAtmosphere()

            VStack(alignment: .leading, spacing: 0) {
                Spacer(minLength: VeiraSpacing.xxl.value)

                Text("Veira")
                    .veiraFont(.displayLarge)
                    .foregroundStyle(theme.colors.textPrimary)
                    .accessibilityAddTraits(.isHeader)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)

                Text("Your skin,\nunderstood.")
                    .veiraFont(.displayMedium)
                    .foregroundStyle(theme.colors.textPrimary)
                    .padding(.top, VeiraSpacing.md.value)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 16)

                Text("Calm scans. Clear progress. A routine that feels effortless.")
                    .veiraFont(.bodyLarge)
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(.top, VeiraSpacing.lg.value)
                    .fixedSize(horizontal: false, vertical: true)
                    .opacity(appeared ? 1 : 0)

                Spacer()

                VStack(spacing: VeiraSpacing.sm.value) {
                    VeiraButton("Get started", icon: .arrowRight, action: onGetStarted)
                    VeiraButton("I already have an account", variant: .ghost, action: onSignIn)
                }
                .opacity(appeared ? 1 : 0)
            }
            .veiraScreenPadding()
            .padding(.bottom, VeiraSpacing.xl.value)
        }
        .onAppear {
            withAnimation(reduceMotion ? nil : VeiraMotion.gentleSpring) {
                appeared = true
            }
        }
    }
}

#Preview {
    WelcomeScreen(onGetStarted: {}, onSignIn: {})
        .veiraThemed()
}
