import Foundation

/// Keys used for UserDefaults persistence
enum UserDefaultsKeys {
    /// Key for storing the app's language preference
    static let appLanguagePreference = "app_language_preference"

    /// Key used by macOS to determine the app's preferred languages
    /// This is a system-level key that affects Locale.current
    static let appleLanguages = "AppleLanguages"

    /// Key for storing the default model preference
    static let defaultModelPreference = "default_model_preference"

    /// Key for storing the app's theme preference (system/light/dark)
    static let appThemePreference = "app_theme_preference"

    /// Key for storing the default truncation strategy preference
    static let defaultTruncationStrategyPreference = "default_truncation_strategy_preference"
}