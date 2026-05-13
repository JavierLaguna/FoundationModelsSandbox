import SwiftUI

// MARK: - Navigation Route
enum NavigationRoute: String, CaseIterable, Hashable {
    case playground
    case history
    case settings

    var icon: String {
        switch self {
        case .playground: "sparkles"
        case .history: "clock.arrow.circlepath"
        case .settings: "gearshape"
        }
    }

    var label: String {
        switch self {
        case .playground: String(localized: "Playground")
        case .history: String(localized: "History")
        case .settings: String(localized: "Settings")
        }
    }

    @ViewBuilder
    var destination: some View {
        switch self {
        case .playground:
            PlaygroundView()
        case .history:
            HistoryView()
        case .settings:
            SettingsView()
        }
    }
}
