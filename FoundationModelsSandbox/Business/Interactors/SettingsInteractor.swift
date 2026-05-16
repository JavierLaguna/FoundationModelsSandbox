import Foundation

/// Handles language preference persistence
protocol SettingsInteractor: Sendable {
    func getCurrentLanguage() -> AppLanguage
    func setLanguage(_ language: AppLanguage)
    func getAvailableLanguages() -> [AppLanguage]
}

final class SettingsInteractorDefault: SettingsInteractor {

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func getCurrentLanguage() -> AppLanguage {
        let storedValue = userDefaults.string(forKey: "app_language_preference")
        return AppLanguage(rawValue: storedValue ?? "") ?? .system
    }

    func setLanguage(_ language: AppLanguage) {
        userDefaults.set(language.rawValue, forKey: "app_language_preference")
        
        // Keep AppleLanguages in sync so Locale.current reflects the selection
        if let identifier = language.localeIdentifier {
            userDefaults.set([identifier], forKey: "AppleLanguages")
        } else {
            userDefaults.removeObject(forKey: "AppleLanguages")
        }
    }

    func getAvailableLanguages() -> [AppLanguage] {
        AppLanguage.allCases
    }
}