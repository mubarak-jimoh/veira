import Foundation
import VeiraDomain

public actor KeychainSessionRepository: SessionRepository {
    private let keychain: any KeychainStore
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let storageKey = "veira.session"

    public init(
        keychain: any KeychainStore,
        encoder: JSONEncoder = KeychainSessionRepository.makeEncoder(),
        decoder: JSONDecoder = KeychainSessionRepository.makeDecoder()
    ) {
        self.keychain = keychain
        self.encoder = encoder
        self.decoder = decoder
    }

    public func currentSession() async throws -> UserSession? {
        guard let data = try keychain.load(forKey: storageKey) else { return nil }
        do {
            return try decoder.decode(UserSession.self, from: data)
        } catch {
            throw KeychainError.decodingFailed
        }
    }

    public func save(_ session: UserSession) async throws {
        do {
            let data = try encoder.encode(session)
            try keychain.save(data, forKey: storageKey)
        } catch is EncodingError {
            throw KeychainError.encodingFailed
        }
    }

    public func clear() async throws {
        try keychain.delete(forKey: storageKey)
    }

    /// Local keychain encoding — stable keys, millisecond dates.
    /// Intentionally distinct from API wire format (`APIJSONCoding`).
    public static func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }

    public static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .millisecondsSince1970
        return decoder
    }
}
