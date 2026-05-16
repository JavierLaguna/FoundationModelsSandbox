import Foundation

/// Keys used for UserDefaults persistence
enum UserDefaultsKeys {
    /// Key for storing the app's language preference
    static let appLanguagePreference = "app_language_preference"
    
    /// Key used by macOS to determine the app's preferred languages
    /// This is a system-level key that affects Locale.current
    static let appleLanguages = "AppleLanguages"
}