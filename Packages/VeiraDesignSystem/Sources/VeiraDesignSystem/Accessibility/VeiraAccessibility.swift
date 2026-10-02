import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Accessibility helpers applied across the design system.
public enum VeiraAccessibility: Sendable {

    /// Minimum interactive target recommended by Apple HIG.
    public static let minimumTapTarget: CGFloat = VeiraLayout.minTapTarget

    /// Whether Reduce Motion is enabled — prefer opacity over offset/scale when true.
    @MainActor
    public static var isReduceMotionEnabled: Bool {
        #if canImport(UIKit)
        UIAccessibility.isReduceMotionEnabled
        #else
        false
        #endif
    }
}

public extension View {
    /// Ensures a control meets the minimum tap target without changing visual size.
    func veiraTapTarget(minSize: CGFloat = VeiraAccessibility.minimumTapTarget) -> some View {
        frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
    }

    /// Applies Reduce Motion–aware animation.
    func veiraAnimation<V: Equatable>(
        _ animation: Animation?,
        value: V
    ) -> some View {
        modifier(ReduceMotionAnimationModifier(animation: animation, value: value))
    }

    /// Marks decorative content as hidden from VoiceOver.
    func veiraDecorative() -> some View {
        accessibilityHidden(true)
    }

    /// Announces transient status changes to VoiceOver.
    func veiraStatusAnnouncement(_ message: String?) -> some View {
        modifier(AccessibilityStatusAnnouncer(message: message))
    }
}

private struct ReduceMotionAnimationModifier<V: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let animation: Animation?
    let value: V

    func body(content: Content) -> some View {
        content.animation(reduceMotion ? .easeInOut(duration: VeiraMotion.instant) : animation, value: value)
    }
}

/// Wrapper that announces loading / error / success state changes to VoiceOver.
public struct AccessibilityStatusAnnouncer: ViewModifier {
    let message: String?

    public init(message: String?) {
        self.message = message
    }

    public func body(content: Content) -> some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(message ?? ""))
            .onChange(of: message) { _, newValue in
                guard let newValue, !newValue.isEmpty else { return }
                #if canImport(UIKit)
                UIAccessibility.post(notification: .announcement, argument: newValue)
                #endif
            }
    }
}
