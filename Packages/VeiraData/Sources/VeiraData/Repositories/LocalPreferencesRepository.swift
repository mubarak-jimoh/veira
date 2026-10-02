import Foundation
import VeiraDomain

public actor LocalPreferencesRepository: PreferencesRepository {
    private let store: any KeyValueStore

    public init(store: any KeyValueStore) {
        self.store = store
    }

    public func bool(for key: PreferenceKey) async -> Bool {
        store.bool(forKey: key.rawValue)
    }

    public func setBool(_ value: Bool, for key: PreferenceKey) async {
        store.setBool(value, forKey: key.rawValue)
    }

    public func string(for key: PreferenceKey) async -> String? {
        store.string(forKey: key.rawValue)
    }

    public func setString(_ value: String?, for key: PreferenceKey) async {
        store.setString(value, forKey: key.rawValue)
    }
}
