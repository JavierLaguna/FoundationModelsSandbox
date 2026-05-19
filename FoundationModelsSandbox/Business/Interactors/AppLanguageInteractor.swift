import Foundation
import Mockable

/// Handles app language preference persistence
@Mockable
protocol AppLanguageInteractor: Sendable {
    func getCurrentLanguage() -> AppLanguage
    func setLanguage(_ language: AppLanguage)
    func getAvailableLanguages() -> [AppLanguage]
}

final class AppLanguageInteractorDefault: AppLanguageInteractor {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getCurrentLanguage() -> AppLanguage {
        let storedValue = userDefaults.string(forKey: UserDefaultsKeys.appLanguagePreference)
        return AppLanguage(rawValue: storedValue ?? "") ?? .system
    }

    func setLanguage(_ language: AppLanguage) {
        userDefaults.set(language.rawValue, forKey: UserDefaultsKeys.appLanguagePreference)
        
        // Keep AppleLanguages in sync so Locale.current reflects the selection
        if let identifier = language.localeIdentifier {
            userDefaults.set([identifier], forKey: UserDefaultsKeys.appleLanguages)
        } else {
            userDefaults.removeObject(forKey: UserDefaultsKeys.appleLanguages)
        }
    }

    func getAvailableLanguages() -> [AppLanguage] {
        AppLanguage.allCases
    }
}