import SwiftUI

/// Complete visual theme for Veira.
public struct VeiraTheme: Sendable, Equatable {
    public let colors: VeiraColors
    public let typography: VeiraTypography
    public let shadows: VeiraShadows
    public let colorScheme: ColorScheme

    public init(
        colors: VeiraColors,
        typography: VeiraTypography = VeiraTypography(),
        shadows: VeiraShadows,
        colorScheme: ColorScheme
    ) {
        self.colors = colors
        self.typography = typography
        self.shadows = shadows
        self.colorScheme = colorScheme
    }

    public static let light = VeiraTheme(
        colors: .light,
        shadows: .light,
        colorScheme: .light
    )

    public static let dark = VeiraTheme(
        colors: .dark,
        shadows: .dark,
        colorScheme: .dark
    )

    public static func resolve(for scheme: ColorScheme) -> VeiraTheme {
        scheme == .dark ? .dark : .light
    }
}

private struct VeiraThemeKey: EnvironmentKey {
    static let defaultValue: VeiraTheme = .light
}

public extension EnvironmentValues {
    var veiraTheme: VeiraTheme {
        get { self[VeiraThemeKey.self] }
        set { self[VeiraThemeKey.self] = newValue }
    }
}

public extension View {
    /// Injects the Veira theme and syncs preferred colour scheme.
    func veiraTheme(_ theme: VeiraTheme) -> some View {
        environment(\.veiraTheme, theme)
            .preferredColorScheme(theme.colorScheme)
    }

    /// Resolves theme from the system colour scheme, with an optional user override.
    func veiraThemed(preferredScheme: ColorScheme? = nil) -> some View {
        modifier(VeiraThemeResolver(preferredScheme: preferredScheme))
    }
}

private struct VeiraThemeResolver: ViewModifier {
    @Environment(\.colorScheme) private var systemColorScheme
    let preferredScheme: ColorScheme?

    func body(content: Content) -> some View {
        let resolvedScheme = preferredScheme ?? systemColorScheme
        content
            .environment(\.veiraTheme, VeiraTheme.resolve(for: resolvedScheme))
            .preferredColorScheme(preferredScheme)
    }
}
