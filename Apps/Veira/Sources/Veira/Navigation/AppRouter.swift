import Foundation
import Observation
import SwiftUI

/// Root application tabs.
public enum AppTab: String, Hashable, CaseIterable, Sendable, Identifiable {
    case home
    case scan
    case progress
    case routine
    case settings

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .home: "Home"
        case .scan: "Scan"
        case .progress: "Progress"
        case .routine: "Routine"
        case .settings: "Settings"
        }
    }
}

/// Typed routes for stack navigation within tabs.
public enum AppRoute: Hashable, Sendable {
    case settingsDetail
    case paywall
    case scanResult
}

/// Root flow after launch.
public enum AppFlow: Hashable, Sendable {
    case launching
    case welcome
    case onboarding
    case authentication
    case permissions
    case main
}

/// Central navigation state — one source of truth for flow, tabs, and stacks.
@MainActor
@Observable
public final class AppRouter {
    public var flow: AppFlow = .launching
    public var selectedTab: AppTab = .home

    public var homePath = NavigationPath()
    public var scanPath = NavigationPath()
    public var progressPath = NavigationPath()
    public var routinePath = NavigationPath()
    public var settingsPath = NavigationPath()

    public init() {}

    public func applyLaunchState(
        hasCompletedOnboarding: Bool,
        isAuthenticated: Bool,
        hasCompletedPermissions: Bool
    ) {
        if !hasCompletedOnboarding {
            flow = .welcome
        } else if !isAuthenticated {
            flow = .authentication
        } else if !hasCompletedPermissions {
            flow = .permissions
        } else {
            flow = .main
        }
    }

    public func showWelcome() {
        flow = .welcome
    }

    public func beginOnboarding() {
        flow = .onboarding
    }

    public func showAuthentication() {
        flow = .authentication
    }

    public func showPermissions() {
        flow = .permissions
    }

    public func enterMain() {
        flow = .main
        selectedTab = .home
    }

    public func select(_ tab: AppTab) {
        if selectedTab == tab {
            popToRoot(tab)
        } else {
            selectedTab = tab
        }
    }

    public func navigate(_ route: AppRoute, on tab: AppTab? = nil) {
        let target = tab ?? selectedTab
        switch target {
        case .home: homePath.append(route)
        case .scan: scanPath.append(route)
        case .progress: progressPath.append(route)
        case .routine: routinePath.append(route)
        case .settings: settingsPath.append(route)
        }
    }

    public func popToRoot(_ tab: AppTab) {
        switch tab {
        case .home: homePath = NavigationPath()
        case .scan: scanPath = NavigationPath()
        case .progress: progressPath = NavigationPath()
        case .routine: routinePath = NavigationPath()
        case .settings: settingsPath = NavigationPath()
        }
    }

    public func binding(for tab: AppTab) -> Binding<NavigationPath> {
        Binding(
            get: {
                switch tab {
                case .home: self.homePath
                case .scan: self.scanPath
                case .progress: self.progressPath
                case .routine: self.routinePath
                case .settings: self.settingsPath
                }
            },
            set: { newValue in
                switch tab {
                case .home: self.homePath = newValue
                case .scan: self.scanPath = newValue
                case .progress: self.progressPath = newValue
                case .routine: self.routinePath = newValue
                case .settings: self.settingsPath = newValue
                }
            }
        )
    }
}
