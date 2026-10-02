import SwiftUI
import VeiraDesignSystem
import VeiraDomain

@MainActor
@Observable
final class RoutineViewModel {
    var selectedPeriod: RoutinePeriod = .morning
    var morning: SkinRoutine
    var evening: SkinRoutine

    init(
        morning: SkinRoutine = SampleData.morningRoutine,
        evening: SkinRoutine = SampleData.eveningRoutine
    ) {
        self.morning = morning
        self.evening = evening
    }

    var activeRoutine: SkinRoutine {
        selectedPeriod == .morning ? morning : evening
    }

    func toggleStep(id: UUID) {
        switch selectedPeriod {
        case .morning:
            morning = toggled(morning, id: id)
        case .evening:
            evening = toggled(evening, id: id)
        }
    }

    private func toggled(_ routine: SkinRoutine, id: UUID) -> SkinRoutine {
        let steps = routine.steps.map { step in
            guard step.id == id else { return step }
            return RoutineStep(
                id: step.id,
                title: step.title,
                detail: step.detail,
                durationSeconds: step.durationSeconds,
                isCompleted: !step.isCompleted,
                symbolName: step.symbolName
            )
        }
        return SkinRoutine(
            id: routine.id,
            title: routine.title,
            period: routine.period,
            steps: steps,
            estimatedMinutes: routine.estimatedMinutes
        )
    }
}

struct RoutineScreen: View {
    @State private var model = RoutineViewModel()
    @Environment(\.veiraTheme) private var theme

    var body: some View {
        VeiraScreen {
            ScrollView {
                VStack(alignment: .leading, spacing: VeiraLayout.sectionSpacing) {
                    header
                    periodPicker
                    progressCard
                    stepsList
                }
                .veiraScreenPadding()
                .padding(.top, VeiraSpacing.md.value)
                .padding(.bottom, VeiraSpacing.xxl.value)
            }
        }
        .veiraNavigationChrome()
        .navigationTitle("Routine")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.xs.value) {
            VeiraOverline(text: "Today")
            Text(model.activeRoutine.title)
                .veiraFont(.displayMedium)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)

            Text("About \(model.activeRoutine.estimatedMinutes) minutes · \(model.activeRoutine.completedCount) of \(model.activeRoutine.steps.count) done")
                .veiraFont(.bodyMedium)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }

    private var periodPicker: some View {
        HStack(spacing: VeiraSpacing.xs.value) {
            ForEach(RoutinePeriod.allCases, id: \.self) { period in
                let selected = model.selectedPeriod == period
                Button {
                    withAnimation(VeiraMotion.snappySpring) {
                        model.selectedPeriod = period
                    }
                } label: {
                    HStack(spacing: VeiraSpacing.xs.value) {
                        Image(systemName: period == .morning ? "sun.max.fill" : "moon.stars.fill")
                            .font(.system(size: 13, weight: .semibold))
                        Text(period.title)
                            .veiraFont(.labelMedium)
                    }
                    .foregroundStyle(selected ? theme.colors.accentContrast : theme.colors.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, VeiraSpacing.sm.value)
                    .background(selected ? theme.colors.accent : theme.colors.surface)
                    .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.md.value, style: .continuous))
                    .overlay {
                        if !selected {
                            RoundedRectangle(cornerRadius: VeiraRadius.md.value, style: .continuous)
                                .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(period.title)
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }

    private var progressCard: some View {
        VeiraCard {
            VStack(alignment: .leading, spacing: VeiraSpacing.sm.value) {
                HStack {
                    Text("Completion")
                        .veiraFont(.labelMedium)
                        .foregroundStyle(theme.colors.textSecondary)
                    Spacer()
                    Text("\(Int(model.activeRoutine.completionProgress * 100))%")
                        .veiraFont(.labelLarge)
                        .foregroundStyle(theme.colors.textPrimary)
                        .monospacedDigit()
                }
                VeiraProgressBar(progress: model.activeRoutine.completionProgress)
            }
        }
    }

    private var stepsList: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.md.value) {
            VeiraSectionHeader(title: "Steps")

            VStack(spacing: VeiraSpacing.sm.value) {
                ForEach(model.activeRoutine.steps) { step in
                    stepRow(step)
                }
            }
        }
    }

    private func stepRow(_ step: RoutineStep) -> some View {
        Button {
            withAnimation(VeiraMotion.snappySpring) {
                model.toggleStep(id: step.id)
            }
        } label: {
            HStack(alignment: .top, spacing: VeiraSpacing.md.value) {
                ZStack {
                    Circle()
                        .strokeBorder(
                            step.isCompleted ? theme.colors.accent : theme.colors.border,
                            lineWidth: 1.5
                        )
                        .frame(width: 28, height: 28)

                    if step.isCompleted {
                        VeiraIconView(.check, size: 12, weight: .bold)
                            .foregroundStyle(theme.colors.accent)
                    }
                }
                .padding(.top, 2)

                VStack(alignment: .leading, spacing: VeiraSpacing.xxs.value) {
                    HStack {
                        Text(step.title)
                            .veiraFont(.titleSmall)
                            .foregroundStyle(theme.colors.textPrimary)
                            .strikethrough(step.isCompleted, color: theme.colors.textTertiary)

                        Spacer()

                        Text("\(step.durationSeconds)s")
                            .veiraFont(.caption)
                            .foregroundStyle(theme.colors.textTertiary)
                            .monospacedDigit()
                    }

                    Text(step.detail)
                        .veiraFont(.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(VeiraSpacing.md.value)
            .background(theme.colors.surface)
            .clipShape(RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: VeiraRadius.lg.value, style: .continuous)
                    .strokeBorder(theme.colors.borderSubtle, lineWidth: 1)
            }
        }
        .buttonStyle(VeiraPressableButtonStyle())
        .accessibilityLabel("\(step.title). \(step.isCompleted ? "Completed" : "Not completed")")
        .accessibilityHint("Double tap to toggle")
    }
}

#Preview {
    NavigationStack {
        RoutineScreen()
    }
    .veiraThemed()
}
