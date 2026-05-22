import Testing
@testable import FoundationModelsSandbox

@MainActor
struct AppThemeTests {

    @Test
    func allCases_containsSystemLightAndDark() {
        let cases = AppTheme.allCases

        #expect(cases.contains(.system))
        #expect(cases.contains(.light))
        #expect(cases.contains(.dark))
        #expect(cases.count == 3)
    }

    @Test
    func displayName_returnsLocalizedString() {
        #expect(!AppTheme.system.displayName.isEmpty)
        #expect(!AppTheme.light.displayName.isEmpty)
        #expect(!AppTheme.dark.displayName.isEmpty)
    }

    @Test(arguments: [
        (AppTheme.system, "system"),
        (.light, "light"),
        (.dark, "dark"),
    ])
    func rawValue(theme: AppTheme, expected: String) {
        #expect(theme.rawValue == expected)
    }

    @Test(arguments: [
        ("system", AppTheme.system),
        ("light", .light),
        ("dark", .dark),
    ])
    func initFromRawValue(rawValue: String, expected: AppTheme) {
        #expect(AppTheme(rawValue: rawValue) == expected)
    }

    @Test
    func initFromRawValue_invalidValue_returnsNil() {
        #expect(AppTheme(rawValue: "invalid") == nil)
        #expect(AppTheme(rawValue: "") == nil)
    }
}
