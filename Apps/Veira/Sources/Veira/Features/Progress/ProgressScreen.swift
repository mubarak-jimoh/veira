import SwiftUI
import VeiraDesignSystem
import VeiraDomain

struct ProgressScreen: View {
    private let snapshots = SampleData.progress
    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var appeared = false

    private var latest: ProgressSnapshot {
        snapshots.first ?? ProgressSnapshot(weekLabel: "This week", score: 0, note: "", capturedAt: Date())
    }

    private var delta: Int {
        guard snapshots.count > 1 else { return 0 }
        return snapshots[0].score - snapshots[1].score
    }

    var body: some View {
        VeiraScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: VeiraLayout.sectionSpacing) {
                    header
                    trendCard
                    chart
                    timeline
                }
                .veiraScreenPadding()
                .padding(.top, VeiraSpacing.md.value)
                .padding(.bottom, VeiraSpacing.xxl.value)
            }
        }
        .veiraNavigationChrome()
        .navigationTitle("Progress")
        .onAppear {
            withAnimation(reduceMotion ? nil : VeiraMotion.gentleSpring) {
                appeared = true
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.xs.value) {
            VeiraOverline(text: "Four-week view")
            Text("Quiet improvement")
                .veiraFont(.displayMedium)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("Your skin score has moved \(abs(delta)) points \(delta >= 0 ? "up" : "down") since last week.")
                .veiraFont(.bodyLarge)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
    }

    private var trendCard: some View {
        VeiraCard {
            HStack(alignment: .center, spacing: VeiraSpacing.lg.value) {
                VStack(alignment: .leading, spacing: VeiraSpacing.xs.value) {
                    Text("Current")
                        .veiraFont(.overline)
                        .foregroundStyle(theme.colors.textTertiary)

                    Text("\(latest.score)")
                        .veiraFont(.displayMedium)
                        .foregroundStyle(theme.colors.textPrimary)
                        .monospacedDigit()

                    Text(delta >= 0 ? "+\(delta) vs last week" : "\(delta) vs last week")
                        .veiraFont(.labelMedium)
                        .foregroundStyle(delta >= 0 ? theme.colors.success : theme.colors.warning)
                }

                Spacer()

                VeiraProgressRing(progress: Double(latest.score) / 100.0, lineWidth: 10)
                    .frame(width: 96, height: 96)
            }
        }
    }

    private var chart: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(title: "Weekly scores")

            HStack(alignment: .bottom, spacing: VeiraSpacing.sm.value) {
                ForEach(Array(snapshots.reversed().enumerated()), id: \.element.id) { _, item in
                    VStack(spacing: VeiraSpacing.xs.value) {
                        Text("\(item.score)")
                            .veiraFont(.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                            .monospacedDigit()
                            .opacity(appeared ? 1 : 0)

                        RoundedRectangle(cornerRadius: VeiraRadius.xs.value, style: .continuous)
                            .fill(theme.colors.accent.opacity(item.id == latest.id ? 1 : 0.35))
                            .frame(height: appeared ? barHeight(for: item.score) : 8)
                            .frame(maxWidth: .infinity)

                        Text(shortLabel(item.weekLabel))
                            .veiraFont(.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(item.weekLabel), score \(item.score)")
                }
            }
            .frame(height: 180, alignment: .bottom)
            .padding(VeiraSpacing.md.value)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            }
        }
    }

    private var timeline: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(title: "Notes")

            VStack(spacing: 0) {
                ForEach(Array(snapshots.enumerated()), id: \.element.id) { index, item in
                    HStack(alignment: .top, spacing: VeiraSpacing.md.value) {
                        Circle()
                            .fill(theme.colors.accent)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                            .accessibilityHidden(true)

                        VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
                            HStack {
                                Text(item.weekLabel)
                                    .veiraFont(.labelMedium)
                                    .foregroundStyle(theme.colors.textPrimary)
                                Spacer()
                                Text("\(item.score)")
                                    .veiraFont(.labelMedium)
                                    .foregroundStyle(theme.colors.accent)
                                    .monospacedDigit()
                            }

                            Text(item.note)
                                .veiraFont(.bodySmall)
                                .foregroundStyle(theme.colors.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.vertical, VeiraSpacing.md.value)

                    if index < snapshots.count - 1 {
                        Divider().overlay(theme.colors.borderSubtle)
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

    private func barHeight(for score: Int) -> CGFloat {
        let minH: CGFloat = 28
        let maxH: CGFloat = 132
        return minH + (maxH - minH) * CGFloat(score) / 100.0
    }

    private func shortLabel(_ week: String) -> String {
        switch week {
        case "This week": "Now"
        case "Last week": "−1w"
        case "2 weeks ago": "−2w"
        case "3 weeks ago": "−3w"
        default: week
        }
    }
}

#Preview {
    NavigationStack {
        ProgressScreen()
    }
    .veiraThemed()
}
