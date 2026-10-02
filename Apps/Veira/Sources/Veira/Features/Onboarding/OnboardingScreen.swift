import SwiftUI
import VeiraDesignSystem
import VeiraDomain

@MainActor
@Observable
final class OnboardingViewModel {
    let pages: [OnboardingPage]
    var index: Int = 0

    init(pages: [OnboardingPage] = SampleData.onboardingPages) {
        self.pages = pages
    }

    var isLastPage: Bool {
        index >= pages.count - 1
    }

    var progress: Double {
        guard !pages.isEmpty else { return 0 }
        return Double(index + 1) / Double(pages.count)
    }

    func advance() {
        guard !isLastPage else { return }
        index += 1
    }

    func goBack() {
        guard index > 0 else { return }
        index -= 1
    }
}

struct OnboardingScreen: View {
    @State private var model = OnboardingViewModel()
    let onFinished: () -> Void
    let onBackToWelcome: () -> Void

    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            VeiraAtmosphere()

            VStack(spacing: VeiraSpacing.xl.value) {
                HStack {
                    Button {
                        if model.index == 0 {
                            onBackToWelcome()
                        } else {
                            withAnimation(VeiraMotion.standardSpring) { model.goBack() }
                        }
                    } label: {
                        VeiraIconView(.chevronLeft, size: 18, weight: .semibold)
                            .foregroundStyle(theme.colors.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(theme.colors.surface.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel("Back")

                    Spacer()

                    VeiraProgressBar(progress: model.progress)
                        .frame(width: 120)

                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.top, VeiraSpacing.sm.value)

                TabView(selection: $model.index) {
                    ForEach(Array(model.pages.enumerated()), id: \.element.id) { offset, page in
                        onboardingPage(page)
                            .tag(offset)
                    }
                }
                #if os(iOS)
                .tabViewStyle(.page(indexDisplayMode: .never))
                #endif
                .animation(reduceMotion ? nil : VeiraMotion.standardSpring, value: model.index)

                VeiraButton(model.isLastPage ? "Continue" : "Next") {
                    if model.isLastPage {
                        onFinished()
                    } else {
                        withAnimation(VeiraMotion.standardSpring) {
                            model.advance()
                        }
                    }
                }
                .padding(.bottom, VeiraSpacing.xl.value)
            }
            .veiraScreenPadding()
        }
    }

    private func onboardingPage(_ page: OnboardingPage) -> some View {
        VStack(spacing: VeiraSpacing.xl.value) {
            Spacer()

            VeiraSymbolBadge(systemName: page.symbolName, size: 88)

            Text(page.title)
                .veiraFont(.displayMedium)
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)

            Text(page.message)
                .veiraFont(.bodyLarge)
                .foregroundStyle(theme.colors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, VeiraSpacing.md.value)

            Spacer()
            Spacer()
        }
    }
}

#Preview {
    OnboardingScreen(onFinished: {}, onBackToWelcome: {})
        .veiraThemed()
}
