import SwiftUI

// MARK: - Navigation Route
enum NavigationRoute: String, CaseIterable, Hashable {
    case playground = "Playground"
    case history = "History"
    case settings = "Settings"

    var icon: String {
        switch self {
        case .playground: "sparkles"
        case .history: "clock.arrow.circlepath"
        case .settings: "gearshape"
        }
    }

    var label: String {
        rawValue
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
