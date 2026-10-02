import SwiftUI

/// Circular score / progress ring.
public struct VeiraProgressRing: View {
    private let progress: Double
    private let lineWidth: CGFloat
    private let showsLabel: Bool
    private let label: String?

    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(
        progress: Double,
        lineWidth: CGFloat = 10,
        showsLabel: Bool = true,
        label: String? = nil
    ) {
        self.progress = min(max(progress, 0), 1)
        self.lineWidth = lineWidth
        self.showsLabel = showsLabel
        self.label = label
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(theme.colors.backgroundSecondary, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    theme.colors.accent,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .veiraAnimation(reduceMotion ? nil : VeiraMotion.gentleSpring, value: progress)

            if showsLabel {
                Text(label ?? "\(Int((progress * 100).rounded()))")
                    .veiraFont(.titleMedium, typography: theme.typography)
                    .foregroundStyle(theme.colors.textPrimary)
                    .monospacedDigit()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label.map { "Progress \($0)" } ?? "Progress \(Int(progress * 100)) percent")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}

/// Linear progress bar.
public struct VeiraProgressBar: View {
    private let progress: Double

    @Environment(\.veiraTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(progress: Double) {
        self.progress = min(max(progress, 0), 1)
    }

    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.colors.backgroundSecondary)

                Capsule()
                    .fill(theme.colors.accent)
                    .frame(width: proxy.size.width * progress)
                    .veiraAnimation(reduceMotion ? nil : VeiraMotion.standardSpring, value: progress)
            }
        }
        .frame(height: 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Progress")
        .accessibilityValue("\(Int(progress * 100)) percent")
    }
}
