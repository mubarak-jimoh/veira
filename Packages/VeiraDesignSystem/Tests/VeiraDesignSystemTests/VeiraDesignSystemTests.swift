import XCTest
@testable import VeiraDesignSystem

final class VeiraSpacingTests: XCTestCase {
    func testBaseGridIsMultiplesOfFour() {
        for spacing in VeiraSpacing.allCases where spacing != .xxxs {
            XCTAssertEqual(Int(spacing.value) % 4, 0, "\(spacing) should sit on a 4pt grid")
        }
    }
}

final class VeiraTypographyTests: XCTestCase {
    func testAllStylesProduceFonts() {
        let typography = VeiraTypography()
        for style in VeiraTypography.Style.allCases {
            _ = typography.scaledFont(for: style)
        }
    }
}

final class VeiraThemeTests: XCTestCase {
    func testResolvesDarkAndLight() {
        XCTAssertEqual(VeiraTheme.resolve(for: .light).colorScheme, .light)
        XCTAssertEqual(VeiraTheme.resolve(for: .dark).colorScheme, .dark)
    }
}
