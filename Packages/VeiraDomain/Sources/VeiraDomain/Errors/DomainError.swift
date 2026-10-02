import Foundation
import VeiraCore

/// Domain errors that features may surface through the UI layer.
public enum DomainError: VeiraError, Equatable {
    case sessionExpired
    case onboardingRequired
    case premiumRequired
    case validation(message: String)
    case notFound(entity: String)
    case conflict(message: String)

    public var userFacingMessage: String {
        switch self {
        case .sessionExpired:
            "Your session expired. Please sign in again."
        case .onboardingRequired:
            "Let’s finish setting up your profile."
        case .premiumRequired:
            "This is part of Veira Premium."
        case .validation(let message):
            message
        case .notFound(let entity):
            "We couldn’t find that \(entity)."
        case .conflict(let message):
            message
        }
    }

    public var isRetryable: Bool {
        switch self {
        case .sessionExpired, .conflict:
            true
        case .onboardingRequired, .premiumRequired, .validation, .notFound:
            false
        }
    }
}
