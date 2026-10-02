import SwiftUI

/// Full-screen or inline loading indicator.
public struct VeiraLoadingView: View {
    private let message: String?

    @Environment(\.veiraTheme) private var theme

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: VeiraSpacing.md.value) {
            ProgressView()
                .controlSize(.large)
                .tint(theme.colors.accent)

            if let message {
                Text(message)
                    .veiraFont(.bodyMedium, typography: theme.typography)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(VeiraSpacing.xl.value)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.map { "Loading. \($0)" } ?? "Loading")
    }
}

/// Shimmer placeholder for content skeletons.
public struct VeiraShimmer: View {
    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    private let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = VeiraRadius.sm.value) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(theme.colors.shimmer)
            .overlay {
                if !reduceMotion {
                    LinearGradient(
                        colors: [
                            .clear,
                            theme.colors.surface.opacity(0.55),
                            .clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .offset(x: phase * 200)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
            .accessibilityHidden(true)
    }
}
