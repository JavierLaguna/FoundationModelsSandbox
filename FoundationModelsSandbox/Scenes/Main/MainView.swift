import SwiftUI
import FoundationModels

// MARK: - Main View (Root Navigation)
struct MainView: View {
    
    /// The real system locale captured at startup, used when System is selected.
    let systemLocale: Locale

    /// Session repository shared across features.
    let sessionRepository: any SessionRepository
    
    @AppStorage(UserDefaultsKeys.appLanguagePreference)
    private var languagePreference: String = AppLanguage.system.rawValue

    @AppStorage(UserDefaultsKeys.appThemePreference)
    private var themePreference: String = AppTheme.system.rawValue
    
    @State private var selectedSection: NavigationRoute = .playground
    @State private var playgroundViewModel: PlaygroundViewModel
    @State private var historyViewModel: HistoryViewModel

    init(systemLocale: Locale, sessionRepository: any SessionRepository) {
        self.systemLocale = systemLocale
        self.sessionRepository = sessionRepository
        self._playgroundViewModel = State(
            initialValue: PlaygroundViewModel(
                sessionRepository: sessionRepository
            )
        )
        self._historyViewModel = State(
            initialValue: HistoryViewModel(
                sessionRepository: sessionRepository
            )
        )
    }

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
                    playgroundViewModel = PlaygroundViewModel(
                        sessionRepository: sessionRepository,
                        shouldRestoreLastSession: false
                    )
                    selectedSection = .playground
                },
                favoriteSessions: historyViewModel.sessions.filter(\.isFavorite),
                onSelectFavorite: { session in
                    playgroundViewModel = PlaygroundViewModel(
                        sessionRepository: sessionRepository,
                        shouldRestoreLastSession: false
                    )
                    playgroundViewModel.loadSession(session)
                    selectedSection = .playground
                }
            )
        } detail: {
            switch selectedSection {
            case .playground:
                PlaygroundView(viewModel: playgroundViewModel)
            case .history:
                HistoryView(
                    viewModel: historyViewModel,
                    onSelectSession: { session in
                        playgroundViewModel = PlaygroundViewModel(
                            sessionRepository: sessionRepository,
                            shouldRestoreLastSession: false
                        )
                        playgroundViewModel.loadSession(session)
                        selectedSection = .playground
                    }
                )
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

// MARK: - Preview Helpers

private final class PreviewSessionRepository: SessionRepository {
    private var sessions: [UUID: ConversationSession] = [:]

    func saveSession(_ session: ConversationSession) throws {
        sessions[session.id] = session
    }

    func updateSession(_ session: ConversationSession) throws {
        sessions[session.id] = session
    }

    func session(id: UUID) throws -> ConversationSession? {
        sessions[id]
    }

    func allSessions() throws -> [ConversationSession] {
        Array(sessions.values).sorted { $0.createdAt > $1.createdAt }
    }

    func lastSession() throws -> ConversationSession? {
        sessions.values.max(by: { $0.createdAt < $1.createdAt })
    }

    func deleteSession(id: UUID) throws {
        sessions.removeValue(forKey: id)
    }

    func deleteAllSessions() throws {
        sessions.removeAll()
    }
}

#Preview {
    MainView(
        systemLocale: .current,
        sessionRepository: PreviewSessionRepository()
    )
    .frame(width: 1200, height: 800)
}
