import Testing
@testable import FoundationModelsSandbox

@MainActor
struct AppLanguageTests {

    @Test
    func allCases_containsSystemEnglishAndSpanish() {
        let cases = AppLanguage.allCases

        #expect(cases.contains(.system))
        #expect(cases.contains(.english))
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

    @Test
    func localeIdentifier_english_returnsEn() {
        #expect(AppLanguage.english.localeIdentifier == "en")
    }

    @Test
    func localeIdentifier_spanish_returnsEs() {
        #expect(AppLanguage.spanish.localeIdentifier == "es")
    }

    @Test
    func rawValue_matchesCaseName() {
        #expect(AppLanguage.system.rawValue == "system")
        #expect(AppLanguage.english.rawValue == "english")
        #expect(AppLanguage.spanish.rawValue == "spanish")
    }

    @Test
    func initFromRawValue_validValues_returnsCorrectCase() {
        #expect(AppLanguage(rawValue: "system") == .system)
        #expect(AppLanguage(rawValue: "english") == .english)
        #expect(AppLanguage(rawValue: "spanish") == .spanish)
    }

    @Test
    func initFromRawValue_invalidValue_returnsNil() {
        #expect(AppLanguage(rawValue: "invalid") == nil)
        #expect(AppLanguage(rawValue: "") == nil)
    }
}