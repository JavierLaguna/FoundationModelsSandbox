import SwiftUI

@main
struct FoundationModelsSandboxApp: App {

    /// Captures the actual system locale at startup, before any stale
    /// `AppleLanguages` key in the app domain can corrupt `Locale.current`.
    private static let systemLocale: Locale = {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "AppleLanguages")
        return Locale.current
    }()

    /// Shared repository for session persistence (SQLite-backed).
    private let sessionRepository: any SessionRepository

    init() {
        // Also clean up on init to handle the case where app_language_preference
        // is "System" but AppleLanguages still has a stale value from a previous version.
        _ = Self.systemLocale
        self.sessionRepository = LiveSessionRepository.makeDefault()
    }

    var body: some Scene {
        WindowGroup {
            MainView(
                systemLocale: Self.systemLocale,
                sessionRepository: sessionRepository
            )
        }
    }
}