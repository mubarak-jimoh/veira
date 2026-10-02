import SwiftUI

/// Navigation bar title treatment.
public struct VeiraNavigationTitle: View {
    private let title: String
    private let subtitle: String?

    @Environment(\.veiraTheme) private var theme

    public init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
    }

    public var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .veiraFont(.titleSmall, typography: theme.typography)
                .foregroundStyle(theme.colors.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .veiraFont(.caption, typography: theme.typography)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

/// Screen chrome: background + horizontal insets.
public struct VeiraScreen<Content: View>: View {
    private let content: Content

    @Environment(\.veiraTheme) private var theme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(theme.colors.background.ignoresSafeArea())
    }
}

/// Horizontal page gutter.
public struct VeiraScreenPadding: ViewModifier {
    public init() {}

    public func body(content: Content) -> some View {
        content.padding(.horizontal, VeiraLayout.screenHorizontal)
    }
}

public extension View {
    func veiraScreenPadding() -> some View {
        modifier(VeiraScreenPadding())
    }

    func veiraNavigationChrome() -> some View {
        toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
    }
}

/// Tab item label using Veira icons with selected/unselected variants.
public struct VeiraTabLabel: View {
    private let title: String
    private let icon: VeiraIcon
    private let selectedIcon: VeiraIcon

    public init(title: String, icon: VeiraIcon, selectedIcon: VeiraIcon? = nil) {
        self.title = title
        self.icon = icon
        self.selectedIcon = selectedIcon ?? icon
    }

    public var body: some View {
        Label {
            Text(title)
        } icon: {
            // TabView swaps symbol variants via the environment; both names are registered
            // so VoiceOver and selected states resolve correctly.
            Image(systemName: icon.systemName)
                .accessibilityHidden(true)
                .overlay {
                    Image(systemName: selectedIcon.systemName)
                        .opacity(0)
                        .accessibilityHidden(true)
                }
        }
        .accessibilityLabel(title)
    }
}
