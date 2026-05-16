import SwiftUI
import FoundationModels

// MARK: - Main View (Root Navigation)
struct MainView: View {
    
    /// The real system locale captured at startup, used when System is selected.
    let systemLocale: Locale
    
    @AppStorage(UserDefaultsKeys.appLanguagePreference)
    private var languagePreference: String = AppLanguage.system.rawValue
    
    @State private var selectedSection: NavigationRoute = .playground
    
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
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $selectedSection)
        } detail: {
            selectedSection.destination
        }
        .navigationSplitViewStyle(.balanced)
        .environment(\.locale, currentLocale)
    }
}

#Preview {
    MainView(systemLocale: .current)
        .frame(width: 1200, height: 800)
}
