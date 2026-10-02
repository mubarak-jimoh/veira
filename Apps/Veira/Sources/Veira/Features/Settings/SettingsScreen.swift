import SwiftUI
import VeiraCore
import VeiraDesignSystem
import VeiraDomain

struct SettingsScreen: View {
    @Environment(AppContainer.self) private var container
    @State private var profile = SampleData.profile
    @State private var analyticsOptIn = true
    @State private var appearanceSelection: AppearanceOption = .system
    @State private var showSignOutConfirm = false

    @Environment(\.veiraTheme) private var theme

    var body: some View {
        VeiraScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: VeiraLayout.sectionSpacing) {
                    profileHeader
                    preferencesSection
                    aboutSection
                    dangerSection
                }
                .veiraScreenPadding()
                .padding(.top, VeiraSpacing.md.value)
                .padding(.bottom, VeiraSpacing.xxl.value)
            }
        }
        .veiraNavigationChrome()
        .navigationTitle("Settings")
        .task {
            profile = await container.authService.currentProfile()
            analyticsOptIn = await container.preferencesRepository.bool(for: .analyticsOptIn)
            appearanceSelection = AppearanceOption(scheme: container.preferredColorScheme)
        }
        .confirmationDialog("Sign out of Veira?", isPresented: $showSignOutConfirm, titleVisibility: .visible) {
            Button("Sign out", role: .destructive) {
                Task { await signOut() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var profileHeader: some View {
        VeiraCard {
            HStack(spacing: VeiraSpacing.md.value) {
                ZStack {
                    Circle()
                        .fill(theme.colors.accentMuted)
                        .frame(width: 64, height: 64)
                    Text(String(profile.firstName.prefix(1)))
                        .veiraFont(.titleLarge)
                        .foregroundStyle(theme.colors.accent)
                }
                .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
                    Text(profile.displayName)
                        .veiraFont(.titleSmall)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text(profile.email)
                        .veiraFont(.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)

                    Text(profile.skinGoal)
                        .veiraFont(.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(title: "Preferences")

            VStack(spacing: 0) {
                appearanceRow
                Divider().overlay(theme.colors.borderSubtle)
                toggleRow(
                    title: "Analytics",
                    subtitle: "Help improve Veira with anonymous usage data",
                    isOn: $analyticsOptIn
                ) { value in
                    Task {
                        await container.preferencesRepository.setBool(value, for: .analyticsOptIn)
                    }
                }
            }
            .padding(.horizontal, VeiraSpacing.md.value)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            }
        }
    }

    private var appearanceRow: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.sm.value) {
            Text("Appearance")
                .veiraFont(.titleSmall)
                .foregroundStyle(theme.colors.textPrimary)

            Picker("Appearance", selection: $appearanceSelection) {
                ForEach(AppearanceOption.allCases) { option in
                    Text(option.title).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .onChange(of: appearanceSelection) { _, newValue in
                Task {
                    await container.setPreferredColorScheme(newValue.colorScheme)
                }
            }
        }
        .padding(.vertical, VeiraSpacing.md.value)
    }

    private func toggleRow(
        title: String,
        subtitle: String,
        isOn: Binding<Bool>,
        onChange: @escaping (Bool) -> Void
    ) -> some View {
        Toggle(isOn: Binding(
            get: { isOn.wrappedValue },
            set: { newValue in
                isOn.wrappedValue = newValue
                onChange(newValue)
            }
        )) {
            VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
                Text(title)
                    .veiraFont(.titleSmall)
                    .foregroundStyle(theme.colors.textPrimary)
                Text(subtitle)
                    .veiraFont(.bodySmall)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .tint(theme.colors.accent)
        .padding(.vertical, VeiraSpacing.md.value)
    }

    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(title: "About")

            VStack(spacing: 0) {
                infoRow(title: "Version", value: container.configuration.appVersion)
                Divider().overlay(theme.colors.borderSubtle)
                infoRow(title: "Build", value: container.configuration.buildNumber)
                Divider().overlay(theme.colors.borderSubtle)
                infoRow(title: "Environment", value: container.configuration.environment.displayName)
            }
            .padding(.horizontal, VeiraSpacing.md.value)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            }
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .veiraFont(.bodyMedium)
                .foregroundStyle(theme.colors.textPrimary)
            Spacer()
            Text(value)
                .veiraFont(.bodyMedium)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(.vertical, VeiraSpacing.md.value)
        .accessibilityElement(children: .combine)
    }

    private var dangerSection: some View {
        VStack(spacing: VeiraSpacing.sm.value) {
            VeiraButton("Sign out", variant: .destructive) {
                showSignOutConfirm = true
            }

            VeiraButton("Reset onboarding", variant: .ghost) {
                Task { await resetOnboarding() }
            }
        }
    }

    private func signOut() async {
        try? await container.authService.signOut()
        await container.preferencesRepository.setBool(false, for: .hasCompletedPermissions)
        container.router.showAuthentication()
    }

    private func resetOnboarding() async {
        try? await container.authService.signOut()
        await container.preferencesRepository.setBool(false, for: .hasCompletedOnboarding)
        await container.preferencesRepository.setBool(false, for: .hasCompletedPermissions)
        container.router.showWelcome()
    }
}

private enum AppearanceOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: "System"
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    init(scheme: ColorScheme?) {
        switch scheme {
        case .some(.light): self = .light
        case .some(.dark): self = .dark
        default: self = .system
        }
    }
}

#Preview {
    NavigationStack {
        SettingsScreen()
    }
    .environment(AppContainer(configuration: EnvironmentConfigurationFactory.make()))
    .veiraThemed()
}
