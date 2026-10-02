import SwiftUI

public enum VeiraButtonVariant: Sendable {
    case primary
    case secondary
    case tertiary
    case destructive
    case ghost
}

public enum VeiraButtonSize: Sendable {
    case large
    case medium
    case small

    /// Visual height. Small uses 40pt visually but expands to the 44pt HIG tap target.
    var height: CGFloat {
        switch self {
        case .large: 56
        case .medium: 48
        case .small: 40
        }
    }

    var minimumTapTarget: CGFloat {
        max(height, VeiraAccessibility.minimumTapTarget)
    }

    var horizontalPadding: CGFloat {
        switch self {
        case .large: VeiraSpacing.lg.value
        case .medium: VeiraSpacing.md.value
        case .small: VeiraSpacing.sm.value
        }
    }

    var fontStyle: VeiraTypography.Style {
        switch self {
        case .large: .labelLarge
        case .medium: .labelMedium
        case .small: .labelSmall
        }
    }
}

/// Primary interactive control for Veira.
public struct VeiraButton: View {
    private let title: String
    private let variant: VeiraButtonVariant
    private let size: VeiraButtonSize
    private let icon: VeiraIcon?
    private let isLoading: Bool
    private let isEnabled: Bool
    private let expands: Bool
    private let action: () -> Void

    @Environment(\.veiraTheme) private var theme
    @Environment(\.isEnabled) private var environmentEnabled

    public init(
        _ title: String,
        variant: VeiraButtonVariant = .primary,
        size: VeiraButtonSize = .large,
        icon: VeiraIcon? = nil,
        isLoading: Bool = false,
        isEnabled: Bool = true,
        expands: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.variant = variant
        self.size = size
        self.icon = icon
        self.isLoading = isLoading
        self.isEnabled = isEnabled
        self.expands = expands
        self.action = action
    }

    private var effectivelyEnabled: Bool {
        isEnabled && environmentEnabled && !isLoading
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: VeiraSpacing.xs.value) {
                if isLoading {
                    ProgressView()
                        .tint(foregroundColor)
                } else if let icon {
                    VeiraIconView(icon, size: size == .small ? 14 : 16, weight: .semibold)
                }

                Text(title)
                    .veiraFont(size.fontStyle, typography: theme.typography)
                    .lineLimit(1)
            }
            .frame(maxWidth: expands ? .infinity : nil)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.md.value, style: .continuous))
            .overlay {
                if variant == .secondary {
                    RoundedRectangle(cornerRadius: VeiraRadius.md.value, style: .continuous)
                        .strokeBorder(theme.colors.border, lineWidth: 1)
                }
            }
        }
        .buttonStyle(VeiraPressableButtonStyle())
        .disabled(!effectivelyEnabled)
        .opacity(effectivelyEnabled ? 1 : 0.48)
        .veiraTapTarget()
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isLoading ? Text("Loading") : Text(""))
    }

    private var foregroundColor: Color {
        switch variant {
        case .primary:
            theme.colors.accentContrast
        case .secondary, .tertiary, .ghost:
            theme.colors.textPrimary
        case .destructive:
            theme.colors.danger
        }
    }

    private var backgroundColor: Color {
        switch variant {
        case .primary:
            theme.colors.accent
        case .secondary:
            theme.colors.surface
        case .tertiary:
            theme.colors.backgroundSecondary
        case .destructive:
            theme.colors.danger.opacity(0.12)
        case .ghost:
            Color.clear
        }
    }
}

public struct VeiraPressableButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed && !reduceMotion ? 0.98 : 1)
            .opacity(configuration.isPressed ? 0.92 : 1)
            .animation(VeiraMotion.snappySpring, value: configuration.isPressed)
    }
}
