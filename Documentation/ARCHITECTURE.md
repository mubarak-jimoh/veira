# Veira Architecture

## Purpose

This document describes the engineering foundation for Veira — a premium AI skincare and wellness iOS application.

The app ships with ten navigable screens that run on sample data. Real skin analysis and a live backend come next.

## Module graph

```
Veira (App)
├── VeiraDesignSystem
├── VeiraDomain
├── VeiraData
│   ├── VeiraNetworking
│   ├── VeiraDomain
│   └── VeiraCore
├── VeiraStoreKit
│   ├── VeiraDomain
│   └── VeiraCore
└── VeiraCore
```

Dependencies flow downward only. Feature code never imports infrastructure details directly — it talks to `VeiraDomain` protocols and receives implementations from `AppContainer`.

## Packages

| Package | Responsibility |
|---------|----------------|
| **VeiraCore** | Environment, logging, analytics protocols, DI primitives, shared errors |
| **VeiraDesignSystem** | Tokens, theme, Dark Mode, accessibility, reusable UI components |
| **VeiraDomain** | Entities, repository protocols, domain errors |
| **VeiraNetworking** | HTTP client, endpoints, interceptors |
| **VeiraData** | Keychain, UserDefaults, disk storage, API client, repository implementations |
| **VeiraStoreKit** | Product IDs, StoreKit 2 purchasing, entitlements |

## Composition root

`AppContainer` is the only place concrete types are constructed. Views and features receive dependencies via:

1. SwiftUI `@Environment` / `@Environment(AppContainer.self)` for UI-facing services
2. `Dependencies.with { … }` task-locals for unstructured async work

There is no service locator, no force-unwrap resolve, and no global mutable singletons.

## Navigation

- `AppFlow` — launching → onboarding → main
- `AppTab` — Today, Scan, Progress, Coach, Profile
- `AppRoute` — typed stack destinations per tab
- `AppRouter` — single source of truth (`@Observable`)

## Design system

- Cool pearl surfaces + muted sage accent (not purple AI chrome, not cream/terracotta)
- Serif display (New York) + SF Pro UI, Dynamic Type enabled
- 4pt spacing grid, continuous corner radii, Reduce Motion–aware animation
- Components: Button, Card, TextField, Progress, Loading, Empty, Error, Navigation chrome

## Configuration

- `Config/*.xcconfig` injects environment + API base URLs into Info.plist
- `EnvironmentConfigurationFactory` reads typed values at launch
- `Config/Veira.storekit` provides local StoreKit testing products

## Testing

- Package tests: `Scripts/verify-foundation.sh` or `swift test --package-path Packages/<Name>`
- App unit tests: `Apps/Veira/Tests`
- UI tests: `Apps/Veira/UITests`
