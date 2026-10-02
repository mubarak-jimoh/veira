import SwiftUI

/// Empty-state layout — one purpose, one action.
public struct VeiraEmptyState: View {
    private let icon: VeiraIcon
    private let title: String
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?

    @Environment(\.veiraTheme) private var theme

    public init(
        icon: VeiraIcon = .empty,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: VeiraSpacing.lg.value) {
            ZStack {
                Circle()
                    .fill(theme.colors.accentMuted)
                    .frame(width: 72, height: 72)

                VeiraIconView(icon, size: 28, weight: .medium)
                    .foregroundStyle(theme.colors.accent)
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

            if let actionTitle, let action {
                VeiraButton(actionTitle, variant: .secondary, size: .medium, expands: false, action: action)
            }
        }
        .padding(.horizontal, VeiraLayout.screenHorizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}
