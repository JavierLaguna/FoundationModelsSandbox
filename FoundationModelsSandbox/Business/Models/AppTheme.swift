import Foundation

/// Supported app color themes.
/// - system: Follows the macOS system appearance.
/// - light: Forces light mode.
/// - dark: Forces dark mode.
enum AppTheme: String, CaseIterable, Sendable {
    case system
    case light
    case dark

    var displayName: String {
        switch self {
        case .system:
            NSLocalizedString("theme_system", comment: "System theme option")
        case .light:
            NSLocalizedString("theme_light", comment: "Light theme option")
        case .dark:
            NSLocalizedString("theme_dark", comment: "Dark theme option")
        }
    }
}
