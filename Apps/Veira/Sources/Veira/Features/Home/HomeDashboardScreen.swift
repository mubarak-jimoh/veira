import SwiftUI
import VeiraCore
import VeiraDesignSystem
import VeiraDomain

@MainActor
@Observable
final class HomeViewModel {
    var profile: UserProfile = SampleData.profile
    var score: SkinScore = SampleData.todayScore
    var routineProgress: Double = SampleData.morningRoutine.completionProgress
    var insights = SampleData.insightCards

    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = profile.firstName
        switch hour {
        case 5..<12: return "Good morning, \(name)"
        case 12..<17: return "Good afternoon, \(name)"
        default: return "Good evening, \(name)"
        }
    }
}

struct HomeDashboardScreen: View {
    @Environment(AppContainer.self) private var container
    @State private var model = HomeViewModel()

    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    var body: some View {
        VeiraScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: VeiraLayout.sectionSpacing) {
                    header
                    scoreHero
                    nextAction
                    insightsSection
                    metricsSection
                }
                .veiraScreenPadding()
                .padding(.top, VeiraSpacing.md.value)
                .padding(.bottom, VeiraSpacing.xxl.value)
            }
        }
        .veiraNavigationChrome()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    container.router.select(.settings)
                } label: {
                    VeiraIconView(.settings, size: 18)
                        .foregroundStyle(theme.colors.textPrimary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Open settings")
            }
        }
        .task {
            model.profile = await container.authService.currentProfile()
            withAnimation(reduceMotion ? nil : VeiraMotion.gentleSpring) {
                appeared = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.xs.value) {
            VeiraOverline(text: formattedDate)
            Text(model.greeting)
                .veiraFont(.displayMedium)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text(model.profile.skinGoal)
                .veiraFont(.bodyMedium)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var scoreHero: some View {
        VeiraCard(elevation: .soft, padding: VeiraSpacing.lg.value) {
            HStack(alignment: .center, spacing: VeiraSpacing.lg.value) {
                VeiraProgressRing(progress: model.score.normalizedProgress, lineWidth: 12)
                    .frame(width: 112, height: 112)
                    .accessibilityLabel("Skin score \(model.score.value)")

                VStack(alignment: .leading, spacing: VeiraSpacing.xs.value) {
                    Text(model.score.band.title)
                        .veiraFont(.overline)
                        .foregroundStyle(theme.colors.accent)

                    Text("Today’s score")
                        .veiraFont(.titleSmall)
                        .foregroundStyle(theme.colors.textPrimary)

                    Text(model.score.summary)
                        .veiraFont(.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .opacity(appeared ? 1 : 0)
    }

    private var nextAction: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(
                title: "Next up",
                subtitle: "Morning routine · \(Int(model.routineProgress * 100))% complete"
            )

            VeiraTappableCard {
                container.router.select(.routine)
            } content: {
                HStack(spacing: VeiraSpacing.md.value) {
                    VeiraSymbolBadge(systemName: "sun.max.fill", size: 48)

                    VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
                        Text("Finish morning reset")
                            .veiraFont(.titleSmall)
                            .foregroundStyle(theme.colors.textPrimary)

                        Text("Serum, moisturiser, and SPF remaining")
                            .veiraFont(.bodySmall)
                            .foregroundStyle(theme.colors.textSecondary)
                    }

                    Spacer()

                    VeiraIconView(.chevronRight, size: 14, weight: .semibold)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
        }
    }

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(title: "Quiet insights")

            VStack(spacing: VeiraSpacing.sm.value) {
                ForEach(Array(model.insights.enumerated()), id: \.offset) { _, card in
                    HStack(alignment: .top, spacing: VeiraSpacing.md.value) {
                        Image(systemName: card.symbol)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(theme.colors.accent)
                            .frame(width: 28)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
                            Text(card.title)
                                .veiraFont(.labelMedium)
                                .foregroundStyle(theme.colors.textPrimary)

                            Text(card.body)
                                .veiraFont(.bodySmall)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, VeiraSpacing.xs.value)
                }
            }
            .padding(VeiraSpacing.md.value)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            }
        }
    }

    private var metricsSection: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(title: "Metrics")

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: VeiraSpacing.sm.value), GridItem(.flexible())],
                spacing: VeiraSpacing.sm.value
            ) {
                ForEach(model.score.metrics) { metric in
                    metricTile(metric)
                }
            }
        }
    }

    private func metricTile(_ metric: SkinMetric) -> some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.sm.value) {
            HStack {
                Image(systemName: metric.symbolName)
                    .foregroundStyle(theme.colors.accent)
                    .accessibilityHidden(true)
                Spacer()
                Text("\(metric.value)")
                    .veiraFont(.titleSmall)
                    .foregroundStyle(theme.colors.textPrimary)
                    .monospacedDigit()
            }

            Text(metric.name)
                .veiraFont(.labelMedium)
                .foregroundStyle(theme.colors.textPrimary)

            VeiraProgressBar(progress: metric.normalizedProgress)

            Text(metric.insight)
                .veiraFont(.caption)
                .foregroundStyle(theme.colors.textTertiary)
                .lineLimit(2)
        }
        .padding(VeiraSpacing.md.value)
        .background(theme.colors.surface)
        .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(metric.name), \(metric.value). \(metric.insight)")
    }

    private var formattedDate: String {
        Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day())
    }
}

#Preview {
    NavigationStack {
        HomeDashboardScreen()
    }
    .environment(AppContainer(configuration: EnvironmentConfigurationFactory.make()))
    .veiraThemed()
}
