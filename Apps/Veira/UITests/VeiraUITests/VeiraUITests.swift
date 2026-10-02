import XCTest

final class VeiraUITests: XCTestCase {
    func testLaunchShowsVeiraBrand() throws {
        let app = XCUIApplication()
        app.launch()

        // Foundation gate or launch surface always exposes the Veira name.
        let brand = app.staticTexts["Veira"]
        XCTAssertTrue(brand.waitForExistence(timeout: 5))
    }
}
