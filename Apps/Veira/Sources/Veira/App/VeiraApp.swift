import SwiftUI
import VeiraCore
import VeiraDesignSystem
import VeiraDomain

@main
struct VeiraApp: App {
    @State private var container: AppContainer

    init() {
        let configuration = EnvironmentConfigurationFactory.make()
        _container = State(initialValue: AppContainer(configuration: configuration))
    }

    var body: some Scene {
        WindowGroup {
            RootView(container: container)
                .veiraThemed(preferredScheme: container.preferredColorScheme)
                .task {
                    await container.withDependencies {
                        await container.start()
                    }
                }
        }
    }
}

struct RootView: View {
    @Bindable var container: AppContainer
    @Environment(\.veiraTheme) private var theme

    var body: some View {
        Group {
            switch container.router.flow {
            case .launching:
                SplashScreen()
                    .transition(VeiraTransition.softScale)

            case .welcome:
                WelcomeScreen(
                    onGetStarted: { container.router.beginOnboarding() },
                    onSignIn: { container.router.showAuthentication() }
                )
                .transition(VeiraTransition.appear)

            case .onboarding:
                OnboardingScreen(
                    onFinished: {
                        Task {
                            await container.withDependencies {
                                await container.completeOnboardingFunnel()
                            }
                        }
                    },
                    onBackToWelcome: { container.router.showWelcome() }
                )
                .transition(VeiraTransition.appear)

            case .authentication:
                AuthScreen(
                    onSuccess: {
                        Task {
                            let permissionsDone = await container.preferencesRepository.bool(for: .hasCompletedPermissions)
                            if permissionsDone {
                                container.router.enterMain()
                            } else {
                                container.router.showPermissions()
                            }
                        }
                    },
                    onBack: { container.router.showWelcome() }
                )
                .transition(VeiraTransition.appear)

            case .permissions:
                PermissionsScreen {
                    container.router.enterMain()
                }
                .transition(VeiraTransition.appear)

            case .main:
                RootTabView(router: container.router)
                    .transition(VeiraTransition.appear)
            }
        }
        .animation(VeiraMotion.standardSpring, value: container.router.flow)
        .environment(container)
        .background(theme.colors.background.ignoresSafeArea())
    }
}
