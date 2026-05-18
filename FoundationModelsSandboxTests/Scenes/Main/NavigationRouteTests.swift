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

    @Test(arguments: [
        (NavigationRoute.playground, "sparkles"),
        (.history, "clock.arrow.circlepath"),
        (.settings, "gearshape"),
    ])
    func icon(route: NavigationRoute, expected: String) {
        #expect(route.icon == expected)
    }

    // MARK: - Label

    @Test(arguments: [
        (NavigationRoute.playground, "Playground"),
        (.history, "History"),
        (.settings, "Settings"),
    ])
    func label(route: NavigationRoute, expected: String) {
        #expect(route.label == LocalizedStringKey(expected))
    }

    // MARK: - Hashable

    @Test
    func conformsToHashable() {
        let routeSet: Set<NavigationRoute> = [.playground, .history, .settings]

        #expect(routeSet.contains(.playground))
        #expect(routeSet.contains(.history))
        #expect(routeSet.contains(.settings))
    }

    // MARK: - RawValue

    @Test(arguments: [
        (NavigationRoute.playground, "playground"),
        (.history, "history"),
        (.settings, "settings"),
    ])
    func rawValue(route: NavigationRoute, expected: String) {
        #expect(route.rawValue == expected)
    }
}