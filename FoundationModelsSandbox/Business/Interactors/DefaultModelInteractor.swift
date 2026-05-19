import Foundation
import Mockable

/// Handles default model preference persistence
@Mockable
protocol DefaultModelInteractor: Sendable {
    func getDefaultModelName() -> String
    func setDefaultModelName(_ name: String)
}

final class DefaultModelInteractorDefault: DefaultModelInteractor {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getDefaultModelName() -> String {
        userDefaults.string(forKey: UserDefaultsKeys.defaultModelPreference) ?? "default"
    }

    func setDefaultModelName(_ name: String) {
        userDefaults.set(name, forKey: UserDefaultsKeys.defaultModelPreference)
    }
}