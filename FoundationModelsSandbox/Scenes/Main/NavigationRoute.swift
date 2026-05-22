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

    var label: LocalizedStringKey {
        switch self {
        case .playground: "Playground"
        case .history: "History"
        case .settings: "Settings"
        }
    }

}
