import SwiftUI
import VeiraCore
import VeiraDesignSystem
import VeiraDomain

@MainActor
@Observable
final class AuthViewModel {
    var displayName = ""
    var email = ""
    var password = ""
    var isCreateAccount = true
    var isLoading = false
    var errorMessage: String?

    var canSubmit: Bool {
        let emailOK = email.contains("@") && email.count > 5
        let nameOK = !isCreateAccount || !displayName.trimmingCharacters(in: .whitespaces).isEmpty
        let passwordOK = password.count >= 6
        return emailOK && nameOK && passwordOK && !isLoading
    }

    func toggleMode() {
        isCreateAccount.toggle()
        errorMessage = nil
    }
}

struct AuthScreen: View {
    @Environment(AppContainer.self) private var container
    @State private var model = AuthViewModel()

    let onSuccess: () -> Void
    let onBack: (() -> Void)?

    @Environment(\.veiraTheme) private var theme

    var body: some View {
        ZStack {
            VeiraAtmosphere()

            ScrollView {
                VStack(alignment: .leading, spacing: VeiraSpacing.xl.value) {
                    if let onBack {
                        Button(action: onBack) {
                            VeiraIconView(.chevronLeft, size: 18, weight: .semibold)
                                .foregroundStyle(theme.colors.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(theme.colors.surface.opacity(0.8))
                                .clipShape(Circle())
                        }
                        .accessibilityLabel("Back")
                        .padding(.top, VeiraSpacing.sm.value)
                    }

                    VStack(alignment: .leading, spacing: VeiraSpacing.sm.value) {
                        VeiraOverline(text: model.isCreateAccount ? "Create account" : "Welcome back")

                        Text(model.isCreateAccount ? "Begin with Veira" : "Sign in")
                            .veiraFont(.displayMedium)
                            .foregroundStyle(theme.colors.textPrimary)
                            .accessibilityAddTraits(.isHeader)

                        Text(
                            model.isCreateAccount
                            ? "A private space for your skin — synced across your devices when you’re ready."
                            : "Continue where you left off."
                        )
                        .veiraFont(.bodyLarge)
                        .foregroundStyle(theme.colors.textSecondary)
                    }

                    VStack(spacing: VeiraSpacing.md.value) {
                        if model.isCreateAccount {
                            VeiraTextField(
                                "Name",
                                text: $model.displayName,
                                placeholder: "Amelia"
                            )
                        }

                        VeiraTextField(
                            "Email",
                            text: $model.email,
                            placeholder: "you@email.com",
                            kind: .email
                        )

                        VeiraTextField(
                            "Password",
                            text: $model.password,
                            placeholder: "At least 6 characters",
                            kind: .password
                        )

                        if let errorMessage = model.errorMessage {
                            Text(errorMessage)
                                .veiraFont(.caption)
                                .foregroundStyle(theme.colors.danger)
                                .accessibilityLabel("Error: \(errorMessage)")
                        }
                    }

                    VStack(spacing: VeiraSpacing.sm.value) {
                        VeiraButton(
                            model.isCreateAccount ? "Create account" : "Sign in",
                            isLoading: model.isLoading,
                            isEnabled: model.canSubmit,
                            action: submit
                        )

                        VeiraButton("Continue as guest", variant: .secondary) {
                            Task { await continueAsGuest() }
                        }

                        Button {
                            withAnimation(VeiraMotion.easeQuick) { model.toggleMode() }
                        } label: {
                            Text(
                                model.isCreateAccount
                                ? "Already have an account? Sign in"
                                : "New here? Create an account"
                            )
                            .veiraFont(.bodySmall)
                            .foregroundStyle(theme.colors.accent)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, VeiraSpacing.sm.value)
                        }
                        .accessibilityLabel(
                            model.isCreateAccount
                            ? "Switch to sign in"
                            : "Switch to create account"
                        )
                    }
                }
                .veiraScreenPadding()
                .padding(.bottom, VeiraSpacing.xxl.value)
            }
        }
    }

    private func submit() {
        Task {
            model.isLoading = true
            model.errorMessage = nil
            defer { model.isLoading = false }

            do {
                let name = model.isCreateAccount
                    ? model.displayName
                    : (model.displayName.isEmpty ? "Veira Member" : model.displayName)
                try await container.authService.signIn(email: model.email, displayName: name)
                await container.analytics.track(.init(name: model.isCreateAccount ? "account_created" : "signed_in"))
                onSuccess()
            } catch let error as DomainError {
                model.errorMessage = error.userFacingMessage
            } catch {
                model.errorMessage = "Something went wrong. Please try again."
            }
        }
    }

    private func continueAsGuest() async {
        model.isLoading = true
        model.errorMessage = nil
        defer { model.isLoading = false }

        do {
            try await container.authService.continueAsGuest()
            await container.analytics.track(.init(name: "continued_as_guest"))
            onSuccess()
        } catch {
            model.errorMessage = "Couldn’t continue as guest. Please try again."
        }
    }
}

#Preview {
    AuthScreen(onSuccess: {}, onBack: {})
        .environment(AppContainer(configuration: EnvironmentConfigurationFactory.make()))
        .veiraThemed()
}
