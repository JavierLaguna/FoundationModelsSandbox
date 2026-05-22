import SwiftUI
import FoundationModels

// MARK: - Main View (Root Navigation)
struct MainView: View {
    
    /// The real system locale captured at startup, used when System is selected.
    let systemLocale: Locale
    
    @AppStorage(UserDefaultsKeys.appLanguagePreference)
    private var languagePreference: String = AppLanguage.system.rawValue

    @AppStorage(UserDefaultsKeys.appThemePreference)
    private var themePreference: String = AppTheme.system.rawValue
    
    @State private var selectedSection: NavigationRoute = .playground
    @State private var playgroundViewModel = PlaygroundViewModel()
    
    private var currentLocale: Locale {
        guard let language = AppLanguage(rawValue: languagePreference) else {
            return systemLocale
        }
        
        return if language != .system,
                  let localeIdentifier = language.localeIdentifier {
            Locale(identifier: localeIdentifier)
            
        } else {
            systemLocale
        }
    }
    
    private var currentTheme: AppTheme {
        AppTheme(rawValue: themePreference) ?? .system
    }

    var body: some View {
        NavigationSplitView {
            SidebarView(
                selectedSection: $selectedSection,
                onNewChat: {
                    playgroundViewModel = PlaygroundViewModel()
                    selectedSection = .playground
                }
            )
        } detail: {
            switch selectedSection {
            case .playground:
                PlaygroundView(viewModel: playgroundViewModel)
            case .history:
                HistoryView()
            case .settings:
                SettingsView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .environment(\.locale, currentLocale)
        .onAppear {
            applyTheme(currentTheme)
        }
        .onChange(of: themePreference) { _, newValue in
            applyTheme(AppTheme(rawValue: newValue) ?? .system)
        }
    }

    private func applyTheme(_ theme: AppTheme) {
        switch theme {
        case .system:
            NSApp.appearance = nil
        case .light:
            NSApp.appearance = NSAppearance(named: .aqua)
        case .dark:
            NSApp.appearance = NSAppearance(named: .darkAqua)
        }
    }
}

#Preview {
    MainView(systemLocale: .current)
        .frame(width: 1200, height: 800)
}
