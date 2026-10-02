import SwiftUI
import VeiraDesignSystem
import VeiraDomain

@MainActor
@Observable
final class ScanViewModel {
    enum Phase: Equatable {
        case ready
        case capturing
        case analyzing
        case result(SkinScore)
    }

    var phase: Phase = .ready

    var isBusy: Bool {
        switch phase {
        case .capturing, .analyzing: true
        default: false
        }
    }

    func startScan() {
        guard !isBusy else { return }
        phase = .capturing
    }

    func advanceAfterCapture() {
        phase = .analyzing
    }

    func complete(with score: SkinScore = SampleData.todayScore) {
        phase = .result(score)
    }

    func reset() {
        phase = .ready
    }
}

struct ScanScreen: View {
    @State private var model = ScanViewModel()
    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VeiraScreen {
            VStack(spacing: VeiraSpacing.xl.value) {
                header

                Spacer(minLength: VeiraSpacing.md.value)

                viewfinder
                    .frame(maxWidth: 320)
                    .aspectRatio(3 / 4, contentMode: .fit)

                statusCopy

                Spacer()

                bottomActions
            }
            .veiraScreenPadding()
            .padding(.top, VeiraSpacing.md.value)
            .padding(.bottom, VeiraSpacing.xl.value)
        }
        .veiraNavigationChrome()
        .navigationTitle("Scan")
        .onChange(of: model.phase) { _, newPhase in
            handlePhaseChange(newPhase)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: VeiraSpacing.xs.value) {
            VeiraOverline(text: "AI Skin Scanner")
            Text(headline)
                .veiraFont(.titleLarge)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var headline: String {
        switch model.phase {
        case .ready: "Frame your face"
        case .capturing: "Hold steady"
        case .analyzing: "Reading your skin"
        case .result: "Scan complete"
        }
    }

    private var viewfinder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: VeiraRadius.xl.value, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            theme.colors.backgroundSecondary,
                            theme.colors.surface
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Soft face guide
            Ellipse()
                .stroke(theme.colors.accent.opacity(0.35), lineWidth: 1.5)
                .padding(48)
                .veiraDecorative()

            RoundedRectangle(cornerRadius: VeiraRadius.xl.value, style: .continuous)
                .strokeBorder(theme.colors.border, lineWidth: 1)

            cornerBrackets

            switch model.phase {
            case .analyzing:
                VeiraLoadingView(message: "Analyzing light & texture")
            case .result(let score):
                VStack(spacing: VeiraSpacing.md.value) {
                    VeiraProgressRing(progress: score.normalizedProgress, lineWidth: 10)
                        .frame(width: 120, height: 120)
                    Text(score.band.title)
                        .veiraFont(.titleSmall)
                        .foregroundStyle(theme.colors.accent)
                }
            case .ready, .capturing:
                VStack(spacing: VeiraSpacing.sm.value) {
                    VeiraIconView(.camera, size: 28)
                        .foregroundStyle(theme.colors.textTertiary)
                    Text(model.phase == .capturing ? "Capturing…" : "Natural light works best")
                        .veiraFont(.bodySmall)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
        }
        .scaleEffect(model.phase == .capturing && !reduceMotion ? 0.985 : 1)
        .animation(VeiraMotion.gentleSpring, value: model.phase)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityViewfinderLabel)
    }

    private var cornerBrackets: some View {
        GeometryReader { proxy in
            let inset: CGFloat = 20
            let length: CGFloat = 28
            let color = theme.colors.accent.opacity(0.7)

            Path { path in
                // Top-left
                path.move(to: CGPoint(x: inset, y: inset + length))
                path.addLine(to: CGPoint(x: inset, y: inset))
                path.addLine(to: CGPoint(x: inset + length, y: inset))
                // Top-right
                path.move(to: CGPoint(x: proxy.size.width - inset - length, y: inset))
                path.addLine(to: CGPoint(x: proxy.size.width - inset, y: inset))
                path.addLine(to: CGPoint(x: proxy.size.width - inset, y: inset + length))
                // Bottom-left
                path.move(to: CGPoint(x: inset, y: proxy.size.height - inset - length))
                path.addLine(to: CGPoint(x: inset, y: proxy.size.height - inset))
                path.addLine(to: CGPoint(x: inset + length, y: proxy.size.height - inset))
                // Bottom-right
                path.move(to: CGPoint(x: proxy.size.width - inset - length, y: proxy.size.height - inset))
                path.addLine(to: CGPoint(x: proxy.size.width - inset, y: proxy.size.height - inset))
                path.addLine(to: CGPoint(x: proxy.size.width - inset, y: proxy.size.height - inset - length))
            }
            .stroke(color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .veiraDecorative()
    }

    private var statusCopy: some View {
        Group {
            switch model.phase {
            case .ready:
                Text("Center your face, then start. Scans stay on device until you choose to sync.")
            case .capturing:
                Text("Keep still for a moment…")
            case .analyzing:
                Text("We’re mapping hydration, clarity, texture, and tone.")
            case .result(let score):
                Text(score.summary)
            }
        }
        .veiraFont(.bodyMedium)
        .foregroundStyle(theme.colors.textSecondary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var bottomActions: some View {
        switch model.phase {
        case .ready:
            VeiraButton("Start scan", icon: .scan, action: model.startScan)
        case .capturing, .analyzing:
            VeiraButton("Working…", isLoading: true, isEnabled: false, action: {})
        case .result:
            VStack(spacing: VeiraSpacing.sm.value) {
                VeiraButton("Scan again", variant: .secondary, action: model.reset)
                VeiraButton("Done") {
                    model.reset()
                }
            }
        }
    }

    private var accessibilityViewfinderLabel: String {
        switch model.phase {
        case .ready: "Camera viewfinder ready"
        case .capturing: "Capturing"
        case .analyzing: "Analyzing"
        case .result(let score): "Result score \(score.value)"
        }
    }

    private func handlePhaseChange(_ phase: ScanViewModel.Phase) {
        switch phase {
        case .capturing:
            Task {
                try? await Task.sleep(for: .milliseconds(900))
                guard !Task.isCancelled else { return }
                model.advanceAfterCapture()
            }
        case .analyzing:
            Task {
                try? await Task.sleep(for: .milliseconds(1600))
                guard !Task.isCancelled else { return }
                model.complete()
            }
        default:
            break
        }
    }
}

#Preview {
    NavigationStack {
        ScanScreen()
    }
    .veiraThemed()
}
