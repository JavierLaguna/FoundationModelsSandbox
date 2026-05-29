import Testing
import Foundation
import FoundationModels
import Mockable
@testable import FoundationModelsSandbox

@MainActor
struct SettingsViewModelTests {

    private static let testSuiteName = "com.foundationmodels.test.settings"

    private static var sampleModel: SystemLanguageModel {
        SystemLanguageModel.default
    }

    /// Returns a clean UserDefaults suite for testing.
    private static func makeUserDefaults() -> UserDefaults {
        let ud = UserDefaults(suiteName: testSuiteName)!
        ud.removePersistentDomain(forName: testSuiteName)
        return ud
    }

    init() {
        MockerPolicy.default = .relaxed
    }

    // MARK: Initialization

    @Test
    func init_setsValuesFromInteractors() {
        let languageInteractor = MockAppLanguageInteractor()
        given(languageInteractor).getCurrentLanguage().willReturn(.english)
        given(languageInteractor).getAvailableLanguages().willReturn([.system, .english, .spanish])

        let modelInteractor = MockDefaultModelInteractor()
        given(modelInteractor).getDefaultModelName().willReturn("test-model")

        let modelsLister = MockListAvailableModelsInteractor()
        given(modelsLister).execute().willReturn([Self.sampleModel])

        let sut = makeSUT(
            languageInteractor: languageInteractor,
            modelInteractor: modelInteractor,
            modelsLister: modelsLister
        )

        #expect(sut.selectedLanguage == .english)
        #expect(sut.availableLanguages == [.system, .english, .spanish])
        #expect(sut.selectedModelName == "test-model")
        #expect(sut.availableModels.count == 1)
        #expect(sut.availableModelNames == ["default"])
        #expect(sut.selectedTheme == .system)
    }

    @Test
    func init_withEmptyModels_setsEmptyModelNames() {
        let languageInteractor = MockAppLanguageInteractor()
        given(languageInteractor).getCurrentLanguage().willReturn(.system)
        given(languageInteractor).getAvailableLanguages().willReturn([])

        let modelInteractor = MockDefaultModelInteractor()
        given(modelInteractor).getDefaultModelName().willReturn("")

        let modelsLister = MockListAvailableModelsInteractor()
        given(modelsLister).execute().willReturn([])

        let sut = makeSUT(
            languageInteractor: languageInteractor,
            modelInteractor: modelInteractor,
            modelsLister: modelsLister
        )

        #expect(sut.availableModels.isEmpty)
        #expect(sut.availableModelNames.isEmpty)
    }

    @Test
    func init_readsStoredThemePreference() {
        let userDefaults = Self.makeUserDefaults()
        userDefaults.set(AppTheme.light.rawValue, forKey: UserDefaultsKeys.appThemePreference)

        let sut = makeSUT(userDefaults: userDefaults)

        #expect(sut.selectedTheme == .light)
    }

    @Test
    func init_withInvalidStoredTheme_fallsBackToSystem() {
        let userDefaults = Self.makeUserDefaults()
        userDefaults.set("invalid_theme", forKey: UserDefaultsKeys.appThemePreference)

        let sut = makeSUT(userDefaults: userDefaults)

        #expect(sut.selectedTheme == .system)
    }

    // MARK: Setters

    @Test
    func selectedLanguageDidSet_callsInteractor() {
        let languageInteractor = MockAppLanguageInteractor()
        given(languageInteractor).getCurrentLanguage().willReturn(.system)
        given(languageInteractor).getAvailableLanguages().willReturn([])

        let modelInteractor = MockDefaultModelInteractor()
        given(modelInteractor).getDefaultModelName().willReturn("")

        let modelsLister = MockListAvailableModelsInteractor()
        given(modelsLister).execute().willReturn([])

        let sut = makeSUT(
            languageInteractor: languageInteractor,
            modelInteractor: modelInteractor,
            modelsLister: modelsLister
        )

        sut.selectedLanguage = .spanish

        verify(languageInteractor).setLanguage(.value(.spanish)).called(.once)
    }

    @Test
    func selectedModelNameDidSet_callsInteractor() {
        let languageInteractor = MockAppLanguageInteractor()
        given(languageInteractor).getCurrentLanguage().willReturn(.system)
        given(languageInteractor).getAvailableLanguages().willReturn([])

        let modelInteractor = MockDefaultModelInteractor()
        given(modelInteractor).getDefaultModelName().willReturn("")

        let modelsLister = MockListAvailableModelsInteractor()
        given(modelsLister).execute().willReturn([])

        let sut = makeSUT(
            languageInteractor: languageInteractor,
            modelInteractor: modelInteractor,
            modelsLister: modelsLister
        )

        sut.selectedModelName = "new-model"

        verify(modelInteractor).setDefaultModelName(.value("new-model")).called(.once)
    }

    // MARK: Computed Properties

    @Test
    func appVersion_returnsNonEmptyString() {
        let sut = makeSUT()

        #expect(!sut.appVersion.isEmpty)
    }

    // MARK: - Theme

    @Test
    func selectedTheme_defaultsToSystem() {
        let sut = makeSUT()

        #expect(sut.selectedTheme == .system)
    }

    @Test
    func availableThemes_containsAllCases() {
        let sut = makeSUT()

        #expect(sut.availableThemes.count == 3)
        #expect(sut.availableThemes.contains(.system))
        #expect(sut.availableThemes.contains(.light))
        #expect(sut.availableThemes.contains(.dark))
    }

    @Test
    func selectedThemeDidSet_persistsToUserDefaults() {
        let userDefaults = Self.makeUserDefaults()

        let sut = makeSUT(userDefaults: userDefaults)

        sut.selectedTheme = .dark

        let stored = userDefaults.string(forKey: UserDefaultsKeys.appThemePreference)
        #expect(stored == AppTheme.dark.rawValue)
    }

    @Test
    func selectedThemeDidSet_overwritesPreviousValue() {
        let userDefaults = Self.makeUserDefaults()
        userDefaults.set(AppTheme.light.rawValue, forKey: UserDefaultsKeys.appThemePreference)

        let sut = makeSUT(userDefaults: userDefaults)
        #expect(sut.selectedTheme == .light)

        sut.selectedTheme = .dark
        #expect(sut.selectedTheme == .dark)

        let stored = userDefaults.string(forKey: UserDefaultsKeys.appThemePreference)
        #expect(stored == AppTheme.dark.rawValue)
    }

    // MARK: - Truncation Strategy

    @Test
    func init_readsTruncationStrategyFromInteractor() {
        let strategyInteractor = MockDefaultTruncationStrategyInteractor()
        given(strategyInteractor).getDefaultTruncationStrategy().willReturn(.summarize)

        let sut = makeSUT(truncationStrategyInteractor: strategyInteractor)

        #expect(sut.selectedTruncationStrategy == .summarize)
    }

    @Test
    func init_withDefaultInteractorValue_returnsDropOldest() {
        let sut = makeSUT()

        #expect(sut.selectedTruncationStrategy == .dropOldest)
    }

    @Test
    func selectedTruncationStrategyDidSet_callsInteractor() {
        let strategyInteractor = MockDefaultTruncationStrategyInteractor()
        given(strategyInteractor).getDefaultTruncationStrategy().willReturn(.dropOldest)

        let sut = makeSUT(truncationStrategyInteractor: strategyInteractor)

        sut.selectedTruncationStrategy = .summarize

        verify(strategyInteractor).setDefaultTruncationStrategy(.value(.summarize)).called(.once)
    }

    @Test
    func selectedTruncationStrategyDidSet_changesProperty() {
        let sut = makeSUT()

        sut.selectedTruncationStrategy = .summarize

        #expect(sut.selectedTruncationStrategy == .summarize)
    }

    // MARK: - Test Helpers

    private func makeSUT(
        languageInteractor: MockAppLanguageInteractor = {
            let mock = MockAppLanguageInteractor()
            given(mock).getCurrentLanguage().willReturn(.system)
            given(mock).getAvailableLanguages().willReturn([])
            return mock
        }(),
        modelInteractor: MockDefaultModelInteractor = {
            let mock = MockDefaultModelInteractor()
            given(mock).getDefaultModelName().willReturn("")
            return mock
        }(),
        truncationStrategyInteractor: MockDefaultTruncationStrategyInteractor = {
            let mock = MockDefaultTruncationStrategyInteractor()
            given(mock).getDefaultTruncationStrategy().willReturn(.dropOldest)
            return mock
        }(),
        modelsLister: MockListAvailableModelsInteractor = {
            let mock = MockListAvailableModelsInteractor()
            given(mock).execute().willReturn([])
            return mock
        }(),
        userDefaults: UserDefaults = makeUserDefaults()
    ) -> SettingsViewModel {
        SettingsViewModel(
            languageInteractor: languageInteractor,
            modelInteractor: modelInteractor,
            truncationStrategyInteractor: truncationStrategyInteractor,
            modelsLister: modelsLister,
            userDefaults: userDefaults
        )
    }
}
