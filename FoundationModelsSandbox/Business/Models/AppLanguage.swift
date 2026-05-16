import Foundation

/// Supported app languages.
/// - system: Follows the macOS system language.
/// - english: Forces English.
/// - spanish: Forces Spanish.
enum AppLanguage: String, CaseIterable, Sendable {
    case system = "System"
    case english = "English"
    case spanish = "Spanish"

    var displayName: String { rawValue }

    var localeIdentifier: String? {
        switch self {
        case .system: nil
        case .english: "en"
        case .spanish: "es"
        }
    }
}
