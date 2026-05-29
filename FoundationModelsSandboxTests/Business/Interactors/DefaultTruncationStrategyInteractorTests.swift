import Foundation
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct DefaultTruncationStrategyInteractorTests {

    // MARK: - Get Default Truncation Strategy

    @Test
    func getDefaultStrategy_withNoStoredValue_returnsDropOldest() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = DefaultTruncationStrategyInteractorDefault(userDefaults: userDefaults)

        let strategy = interactor.getDefaultTruncationStrategy()

        #expect(strategy == .dropOldest)
    }

    @Test
    func getDefaultStrategy_withStoredSummarize_returnsSummarize() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set(
            ContextTruncationStrategy.summarize.rawValue,
            forKey: UserDefaultsKeys.defaultTruncationStrategyPreference
        )
        let interactor = DefaultTruncationStrategyInteractorDefault(userDefaults: userDefaults)

        let strategy = interactor.getDefaultTruncationStrategy()

        #expect(strategy == .summarize)
    }

    @Test
    func getDefaultStrategy_withDropOldest_returnsDropOldest() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set(
            ContextTruncationStrategy.dropOldest.rawValue,
            forKey: UserDefaultsKeys.defaultTruncationStrategyPreference
        )
        let interactor = DefaultTruncationStrategyInteractorDefault(userDefaults: userDefaults)

        let strategy = interactor.getDefaultTruncationStrategy()

        #expect(strategy == .dropOldest)
    }

    @Test
    func getDefaultStrategy_withInvalidStoredValue_fallsBackToDropOldest() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set("invalid_strategy", forKey: UserDefaultsKeys.defaultTruncationStrategyPreference)
        let interactor = DefaultTruncationStrategyInteractorDefault(userDefaults: userDefaults)

        let strategy = interactor.getDefaultTruncationStrategy()

        #expect(strategy == .dropOldest)
    }

    // MARK: - Set Default Truncation Strategy

    @Test
    func setDefaultStrategy_storesValueInUserDefaults() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = DefaultTruncationStrategyInteractorDefault(userDefaults: userDefaults)

        interactor.setDefaultTruncationStrategy(.summarize)

        #expect(
            userDefaults.string(forKey: UserDefaultsKeys.defaultTruncationStrategyPreference)
            == ContextTruncationStrategy.summarize.rawValue
        )
    }

    @Test
    func setDefaultStrategy_overwritesPreviousValue() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set(
            ContextTruncationStrategy.dropOldest.rawValue,
            forKey: UserDefaultsKeys.defaultTruncationStrategyPreference
        )
        let interactor = DefaultTruncationStrategyInteractorDefault(userDefaults: userDefaults)

        interactor.setDefaultTruncationStrategy(.summarize)

        #expect(
            userDefaults.string(forKey: UserDefaultsKeys.defaultTruncationStrategyPreference)
            == ContextTruncationStrategy.summarize.rawValue
        )
    }

    // MARK: - Round Trip

    @Test
    func setAndGetDefaultStrategy_roundTrip_returnsSameValue() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = DefaultTruncationStrategyInteractorDefault(userDefaults: userDefaults)

        interactor.setDefaultTruncationStrategy(.summarize)
        let retrieved = interactor.getDefaultTruncationStrategy()

        #expect(retrieved == .summarize)
    }
}
