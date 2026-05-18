import Testing
@testable import FoundationModelsSandbox

@MainActor
struct AppLanguageTests {

    @Test
    func allCases_containsSystemEnglishAndSpanish() {
        let cases = AppLanguage.allCases

        #expect(cases.contains(.system))
        #expect(cases.contains(.english))
        #expect(cases.contains(.spanish))
        #expect(cases.count == 3)
    }

    @Test
    func displayName_returnsLocalizedString() {
        // System should return localized "System" string
        #expect(!AppLanguage.system.displayName.isEmpty)
        #expect(!AppLanguage.english.displayName.isEmpty)
        #expect(!AppLanguage.spanish.displayName.isEmpty)
    }

    @Test
    func localeIdentifier_system_returnsNil() {
        #expect(AppLanguage.system.localeIdentifier == nil)
    }

    @Test(arguments: [
        (AppLanguage.english, "en"),
        (.spanish, "es"),
    ])
    func localeIdentifier(language: AppLanguage, expected: String) {
        #expect(language.localeIdentifier == expected)
    }

    @Test(arguments: [
        (AppLanguage.system, "system"),
        (.english, "english"),
        (.spanish, "spanish"),
    ])
    func rawValue(language: AppLanguage, expected: String) {
        #expect(language.rawValue == expected)
    }

    @Test(arguments: [
        ("system", AppLanguage.system),
        ("english", .english),
        ("spanish", .spanish),
    ])
    func initFromRawValue(rawValue: String, expected: AppLanguage) {
        #expect(AppLanguage(rawValue: rawValue) == expected)
    }

    @Test
    func initFromRawValue_invalidValue_returnsNil() {
        #expect(AppLanguage(rawValue: "invalid") == nil)
        #expect(AppLanguage(rawValue: "") == nil)
    }
}