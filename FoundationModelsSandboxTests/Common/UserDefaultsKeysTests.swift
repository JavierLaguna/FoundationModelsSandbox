import Testing
@testable import FoundationModelsSandbox

@MainActor
struct UserDefaultsKeysTests {

    // MARK: - Keys exist

    @Test
    func appLanguagePreference_keyExists() {
        #expect(UserDefaultsKeys.appLanguagePreference == "app_language_preference")
    }

    @Test
    func appleLanguages_keyExists() {
        #expect(UserDefaultsKeys.appleLanguages == "AppleLanguages")
    }

    @Test
    func defaultModelPreference_keyExists() {
        #expect(UserDefaultsKeys.defaultModelPreference == "default_model_preference")
    }

    // MARK: - Keys are non-empty

    @Test
    func allKeys_areNonEmptyStrings() {
        #expect(!UserDefaultsKeys.appLanguagePreference.isEmpty)
        #expect(!UserDefaultsKeys.appleLanguages.isEmpty)
        #expect(!UserDefaultsKeys.defaultModelPreference.isEmpty)
    }

    // MARK: - Keys are unique

    @Test
    func allKeys_areUnique() {
        let keys = [
            UserDefaultsKeys.appLanguagePreference,
            UserDefaultsKeys.appleLanguages,
            UserDefaultsKeys.defaultModelPreference
        ]
        let uniqueKeys = Set(keys)
        #expect(keys.count == uniqueKeys.count)
    }
}