import SwiftUI
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct NavigationRouteTests {

    // MARK: - CaseIterable

    @Test
    func allCases_containsPlaygroundHistoryAndSettings() {
        let cases = NavigationRoute.allCases

        #expect(cases.contains(.playground))
        #expect(cases.contains(.history))
        #expect(cases.contains(.settings))
        #expect(cases.count == 3)
    }

    // MARK: - Icon

    @Test
    func icon_playground_returnsSparkles() {
        #expect(NavigationRoute.playground.icon == "sparkles")
    }

    @Test
    func icon_history_returnsClockArrowCirclepath() {
        #expect(NavigationRoute.history.icon == "clock.arrow.circlepath")
    }

    @Test
    func icon_settings_returnsGearshape() {
        #expect(NavigationRoute.settings.icon == "gearshape")
    }

    // MARK: - Label

    @Test
    func label_playground_returnsLocalizedPlayground() {
        #expect(NavigationRoute.playground.label == "Playground")
    }

    @Test
    func label_history_returnsLocalizedHistory() {
        #expect(NavigationRoute.history.label == "History")
    }

    @Test
    func label_settings_returnsLocalizedSettings() {
        #expect(NavigationRoute.settings.label == "Settings")
    }

    // MARK: - Hashable

    @Test
    func conformsToHashable() {
        let route: NavigationRoute = .playground

        // Test that NavigationRoute can be used in a Set (requires Hashable)
        var routeSet: Set<NavigationRoute> = [.playground, .history, .settings]

        #expect(routeSet.contains(.playground))
        #expect(routeSet.contains(.history))
        #expect(routeSet.contains(.settings))
    }

    // MARK: - RawValue

    @Test
    func rawValue_playground_returnsPlayground() {
        #expect(NavigationRoute.playground.rawValue == "playground")
    }

    @Test
    func rawValue_history_returnsHistory() {
        #expect(NavigationRoute.history.rawValue == "history")
    }

    @Test
    func rawValue_settings_returnsSettings() {
        #expect(NavigationRoute.settings.rawValue == "settings")
    }
}