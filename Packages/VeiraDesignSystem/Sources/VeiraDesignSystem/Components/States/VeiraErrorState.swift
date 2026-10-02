import SwiftUI

/// Error-state layout with optional retry.
public struct VeiraErrorState: View {
    private let title: String
    private let message: String
    private let retryTitle: String
    private let onRetry: (() -> Void)?

    @Environment(\.veiraTheme) private var theme

    public init(
        title: String = "Something went wrong",
        message: String,
        retryTitle: String = "Try again",
        onRetry: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    public var body: some View {
        VStack(spacing: VeiraSpacing.lg.value) {
            ZStack {
                Circle()
                    .fill(theme.colors.danger.opacity(0.12))
                    .frame(width: 72, height: 72)

                VeiraIconView(.error, size: 28, weight: .medium)
                    .foregroundStyle(theme.colors.danger)
            }
            .veiraDecorative()

            VStack(spacing: VeiraSpacing.xs.value) {
                Text(title)
                    .veiraFont(.titleSmall, typography: theme.typography)
                    .foregroundStyle(theme.colors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(message)
                    .veiraFont(.bodyMedium, typography: theme.typography)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let onRetry {
                VeiraButton(retryTitle, variant: .primary, size: .medium, icon: .retry, expands: false, action: onRetry)
            }
        }
        .padding(.horizontal, VeiraLayout.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}

/// Compact inline error banner.
public struct VeiraInlineError: View {
    private let message: String

    @Environment(\.veiraTheme) private var theme

    public init(message: String) {
        self.message = message
    }

    public var body: some View {
        HStack(alignment: .top, spacing: VeiraSpacing.sm.value) {
            VeiraIconView(.warning, size: 16)
                .foregroundStyle(theme.colors.danger)

            Text(message)
                .veiraFont(.bodySmall, typography: theme.typography)
                .foregroundStyle(theme.colors.danger)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(VeiraSpacing.sm.value)
        .background(theme.colors.danger.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.sm.value, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}
