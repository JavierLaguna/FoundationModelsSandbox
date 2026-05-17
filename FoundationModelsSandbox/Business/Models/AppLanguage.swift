import Foundation

/// Supported app languages.
/// - system: Follows the macOS system language.
/// - english: Forces English.
/// - spanish: Forces Spanish.
enum AppLanguage: String, CaseIterable, Sendable {
    case system
    case english
    case spanish

    var displayName: String {
        switch self {
        case .system: String(localized: "system_language")
        case .english: String(localized: "english_language")
        case .spanish: String(localized: "spanish_language")
        }
    }

    var localeIdentifier: String? {
        switch self {
        case .system: nil
        case .english: "en"
        case .spanish: "es"
        }
    }
}
