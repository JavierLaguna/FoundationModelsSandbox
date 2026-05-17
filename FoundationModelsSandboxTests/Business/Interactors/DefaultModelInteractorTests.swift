import Foundation
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct DefaultModelInteractorTests {

    // MARK: - Get Default Model Name

    @Test
    func getDefaultModelName_withNoStoredValue_returnsDefault() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = DefaultModelInteractorDefault(userDefaults: userDefaults)

        let modelName = interactor.getDefaultModelName()

        #expect(modelName == "default")
    }

    @Test
    func getDefaultModelName_withStoredValue_returnsStoredValue() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set("gpt-4o", forKey: UserDefaultsKeys.defaultModelPreference)
        let interactor = DefaultModelInteractorDefault(userDefaults: userDefaults)

        let modelName = interactor.getDefaultModelName()

        #expect(modelName == "gpt-4o")
    }

    @Test
    func getDefaultModelName_withEmptyString_returnsEmptyString() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set("", forKey: UserDefaultsKeys.defaultModelPreference)
        let interactor = DefaultModelInteractorDefault(userDefaults: userDefaults)

        let modelName = interactor.getDefaultModelName()

        // Empty string is returned as-is, not replaced with "default"
        #expect(modelName == "")
    }

    // MARK: - Set Default Model Name

    @Test
    func setDefaultModelName_storesValueInUserDefaults() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = DefaultModelInteractorDefault(userDefaults: userDefaults)

        interactor.setDefaultModelName("claude-3-sonnet")

        #expect(userDefaults.string(forKey: UserDefaultsKeys.defaultModelPreference) == "claude-3-sonnet")
    }

    @Test
    func setDefaultModelName_overwritesPreviousValue() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set("old-model", forKey: UserDefaultsKeys.defaultModelPreference)
        let interactor = DefaultModelInteractorDefault(userDefaults: userDefaults)

        interactor.setDefaultModelName("new-model")

        #expect(userDefaults.string(forKey: UserDefaultsKeys.defaultModelPreference) == "new-model")
    }

    @Test
    func setDefaultModelName_withEmptyString_storesEmptyString() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = DefaultModelInteractorDefault(userDefaults: userDefaults)

        interactor.setDefaultModelName("")

        #expect(userDefaults.string(forKey: UserDefaultsKeys.defaultModelPreference) == "")
    }

    // MARK: - Round Trip

    @Test
    func setAndGetDefaultModelName_roundTrip_returnsSameValue() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = DefaultModelInteractorDefault(userDefaults: userDefaults)

        interactor.setDefaultModelName("test-model")
        let retrieved = interactor.getDefaultModelName()

        #expect(retrieved == "test-model")
    }
}