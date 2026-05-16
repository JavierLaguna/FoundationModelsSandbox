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

    init() {
        // Also clean up on init to handle the case where app_language_preference
        // is "System" but AppleLanguages still has a stale value from a previous version.
        _ = Self.systemLocale
    }

    var body: some Scene {
        WindowGroup {
            MainView(systemLocale: Self.systemLocale)
        }
    }
}