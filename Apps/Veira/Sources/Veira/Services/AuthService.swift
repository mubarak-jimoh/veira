import Foundation
import VeiraCore
import VeiraDomain

/// Local authentication for the first shippable shell — no backend required.
@MainActor
public final class AuthService {
    private let sessionRepository: any SessionRepository
    private let preferencesRepository: any PreferencesRepository
    private let logger: any Logging
    private let clock: any ClockProviding

    public init(
        sessionRepository: any SessionRepository,
        preferencesRepository: any PreferencesRepository,
        logger: any Logging,
        clock: any ClockProviding
    ) {
        self.sessionRepository = sessionRepository
        self.preferencesRepository = preferencesRepository
        self.logger = logger
        self.clock = clock
    }

    public func signIn(email: String, displayName: String) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let name = displayName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, trimmedEmail.contains("@") else {
            throw DomainError.validation(message: "Enter a valid email address.")
        }
        guard !name.isEmpty else {
            throw DomainError.validation(message: "Enter your name.")
        }

        let session = UserSession(
            userID: UserID(),
            accessToken: "local.\(UUID().uuidString)",
            refreshToken: "refresh.\(UUID().uuidString)",
            expiresAt: clock.now().addingTimeInterval(60 * 60 * 24 * 30)
        )

        try await sessionRepository.save(session)
        await preferencesRepository.setString(name, for: .displayName)
        await preferencesRepository.setString(trimmedEmail, for: .accountEmail)
        await preferencesRepository.setString(SampleData.profile.skinGoal, for: .skinGoal)

        logger.info("Local session created for \(trimmedEmail)", category: .auth)
    }

    public func continueAsGuest() async throws {
        try await signIn(email: "guest@veira.local", displayName: "Guest")
    }

    public func signOut() async throws {
        try await sessionRepository.clear()
        logger.info("Session cleared", category: .auth)
    }

    public func currentProfile() async -> UserProfile {
        let name = await preferencesRepository.string(for: .displayName) ?? SampleData.profile.displayName
        let email = await preferencesRepository.string(for: .accountEmail) ?? SampleData.profile.email
        let goal = await preferencesRepository.string(for: .skinGoal) ?? SampleData.profile.skinGoal
        return UserProfile(
            displayName: name,
            email: email,
            skinGoal: goal,
            memberSince: SampleData.profile.memberSince
        )
    }
}
