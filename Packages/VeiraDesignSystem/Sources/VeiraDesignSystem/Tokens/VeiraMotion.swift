import SwiftUI

/// Motion tokens — subtle, purposeful, never decorative noise.
public enum VeiraMotion: Sendable {
    public static let instant: Double = 0.12
    public static let quick: Double = 0.20
    public static let standard: Double = 0.32
    public static let emphasis: Double = 0.48
    public static let dramatic: Double = 0.64

    public static var standardSpring: Animation {
        .spring(response: 0.38, dampingFraction: 0.86)
    }

    public static var gentleSpring: Animation {
        .spring(response: 0.52, dampingFraction: 0.90)
    }

    public static var snappySpring: Animation {
        .spring(response: 0.28, dampingFraction: 0.82)
    }

    public static var easeStandard: Animation {
        .easeInOut(duration: standard)
    }

    public static var easeQuick: Animation {
        .easeInOut(duration: quick)
    }

    public static var fade: Animation {
        .easeOut(duration: quick)
    }
}

/// View transitions used across the design system.
public enum VeiraTransition: Sendable {
    public static var appear: AnyTransition {
        .opacity.combined(with: .offset(y: 8))
    }

    public static var softScale: AnyTransition {
        .opacity.combined(with: .scale(scale: 0.98))
    }
}
