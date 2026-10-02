import SwiftUI

/// SF Symbol catalog used by Veira chrome.
///
/// Centralising icon names prevents stringly-typed drift across features.
public enum VeiraIcon: String, Sendable, CaseIterable {
    case home = "house"
    case homeFill = "house.fill"
    case scan = "viewfinder"
    case scanFill = "viewfinder.circle.fill"
    case progress = "chart.line.uptrend.xyaxis"
    case coach = "sparkles"
    case profile = "person"
    case profileFill = "person.fill"
    case chevronRight = "chevron.right"
    case chevronLeft = "chevron.left"
    case close = "xmark"
    case check = "checkmark"
    case checkCircle = "checkmark.circle.fill"
    case warning = "exclamationmark.triangle.fill"
    case error = "xmark.octagon.fill"
    case info = "info.circle.fill"
    case plus = "plus"
    case camera = "camera.fill"
    case water = "drop.fill"
    case sleep = "moon.fill"
    case nutrition = "leaf.fill"
    case fitness = "figure.run"
    case lock = "lock.fill"
    case settings = "gearshape"
    case share = "square.and.arrow.up"
    case empty = "tray"
    case retry = "arrow.clockwise"
    case star = "star.fill"
    case sun = "sun.max.fill"
    case moon = "moon.stars.fill"
    case bell = "bell.fill"
    case calendar = "calendar"
    case face = "face.smiling.inverse"
    case droplet = "drop.circle.fill"
    case sparkle = "sparkle"
    case envelope = "envelope.fill"
    case personCircle = "person.crop.circle.fill"
    case arrowRight = "arrow.right"
    case eye = "eye.fill"
    case shield = "lock.shield.fill"
    case chart = "chart.bar.fill"
    case list = "list.bullet"
    case clock = "clock.fill"

    public var systemName: String { rawValue }
}

public struct VeiraIconView: View {
    private let icon: VeiraIcon
    private let pointSize: CGFloat
    private let weight: Font.Weight
    private let scalesWithDynamicType: Bool

    public init(
        _ icon: VeiraIcon,
        size: CGFloat = 20,
        weight: Font.Weight = .regular,
        scalesWithDynamicType: Bool = true
    ) {
        self.icon = icon
        self.pointSize = size
        self.weight = weight
        self.scalesWithDynamicType = scalesWithDynamicType
    }

    public var body: some View {
        Image(systemName: icon.systemName)
            .font(iconFont)
            .imageScale(.medium)
            .accessibilityHidden(true)
    }

    private var iconFont: Font {
        .system(size: pointSize, weight: weight)
    }
}
