import XCTest
@testable import Veira

final class AppRouterTests: XCTestCase {
    @MainActor
    func testLaunchRoutesToWelcomeWhenOnboardingIncomplete() {
        let router = AppRouter()
        router.applyLaunchState(
            hasCompletedOnboarding: false,
            isAuthenticated: false,
            hasCompletedPermissions: false
        )
        XCTAssertEqual(router.flow, .welcome)
    }

    @MainActor
    func testLaunchRoutesToAuthWhenOnboardedButSignedOut() {
        let router = AppRouter()
        router.applyLaunchState(
            hasCompletedOnboarding: true,
            isAuthenticated: false,
            hasCompletedPermissions: false
        )
        XCTAssertEqual(router.flow, .authentication)
    }

    @MainActor
    func testLaunchRoutesToPermissionsWhenAuthedWithoutPermissions() {
        let router = AppRouter()
        router.applyLaunchState(
            hasCompletedOnboarding: true,
            isAuthenticated: true,
            hasCompletedPermissions: false
        )
        XCTAssertEqual(router.flow, .permissions)
    }

    @MainActor
    func testLaunchRoutesToMainWhenFullyReady() {
        let router = AppRouter()
        router.applyLaunchState(
            hasCompletedOnboarding: true,
            isAuthenticated: true,
            hasCompletedPermissions: true
        )
        XCTAssertEqual(router.flow, .main)
    }

    @MainActor
    func testEnterMainSelectsHome() {
        let router = AppRouter()
        router.showAuthentication()
        router.enterMain()
        XCTAssertEqual(router.flow, .main)
        XCTAssertEqual(router.selectedTab, .home)
    }

    @MainActor
    func testSelectingSameTabPopsToRoot() {
        let router = AppRouter()
        router.homePath.append(AppRoute.settingsDetail)
        router.select(.home)
        XCTAssertTrue(router.homePath.isEmpty)
    }
}
