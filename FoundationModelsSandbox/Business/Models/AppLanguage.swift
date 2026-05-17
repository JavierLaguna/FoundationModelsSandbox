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
        case .system:
            NSLocalizedString("system_language", comment: "System language option")
        case .english:
            NSLocalizedString("english_language", comment: "English language option")
        case .spanish:
            NSLocalizedString("spanish_language", comment: "Spanish language option")
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
