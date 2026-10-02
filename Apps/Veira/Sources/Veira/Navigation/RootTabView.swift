import SwiftUI
import VeiraDesignSystem

/// Root tab shell with the five primary product surfaces.
struct RootTabView: View {
    @Bindable var router: AppRouter
    @Environment(\.veiraTheme) private var theme

    private var tabSelection: Binding<AppTab> {
        Binding(
            get: { router.selectedTab },
            set: { router.select($0) }
        )
    }

    var body: some View {
        TabView(selection: tabSelection) {
            tabNavigation(.home) {
                HomeDashboardScreen()
            }
            .tabItem {
                VeiraTabLabel(title: AppTab.home.title, icon: .home, selectedIcon: .homeFill)
            }
            .tag(AppTab.home)

            tabNavigation(.scan) {
                ScanScreen()
            }
            .tabItem {
                VeiraTabLabel(title: AppTab.scan.title, icon: .scan, selectedIcon: .scanFill)
            }
            .tag(AppTab.scan)

            tabNavigation(.progress) {
                ProgressScreen()
            }
            .tabItem {
                VeiraTabLabel(title: AppTab.progress.title, icon: .progress)
            }
            .tag(AppTab.progress)

            tabNavigation(.routine) {
                RoutineScreen()
            }
            .tabItem {
                VeiraTabLabel(title: AppTab.routine.title, icon: .list, selectedIcon: .list)
            }
            .tag(AppTab.routine)

            tabNavigation(.settings) {
                SettingsScreen()
            }
            .tabItem {
                VeiraTabLabel(title: AppTab.settings.title, icon: .settings, selectedIcon: .settings)
            }
            .tag(AppTab.settings)
        }
        .tint(theme.colors.accent)
    }

    @ViewBuilder
    private func tabNavigation<Content: View>(
        _ tab: AppTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack(path: router.binding(for: tab)) {
            content()
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .settingsDetail:
                        SettingsScreen()
                    case .paywall:
                        PaywallPlaceholderScreen()
                    case .scanResult:
                        ProgressScreen()
                    }
                }
        }
    }
}

/// Lightweight paywall placeholder connected to StoreKit foundation.
struct PaywallPlaceholderScreen: View {
    @Environment(\.veiraTheme) private var theme

    var body: some View {
        VeiraScreen {
            VStack(alignment: .leading, spacing: VeiraSpacing.lg.value) {
                Text("Veira Premium")
                    .veiraFont(.displayMedium)
                    .foregroundStyle(theme.colors.textPrimary)

                Text("Deeper insights, unlimited scans, and personalized coaching — coming with StoreKit checkout.")
                    .veiraFont(.bodyLarge)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer()
            }
            .veiraScreenPadding()
            .padding(.top, VeiraSpacing.xl.value)
        }
        .veiraNavigationChrome()
        .navigationTitle("Premium")
    }
}
