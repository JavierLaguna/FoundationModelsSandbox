import Testing
import Foundation
import FoundationModels
import Mockable
@testable import FoundationModelsSandbox

@MainActor
struct SettingsViewModelTests {
    
    private static var sampleModel: SystemLanguageModel {
        SystemLanguageModel.default
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
        modelsLister: MockListAvailableModelsInteractor = {
            let mock = MockListAvailableModelsInteractor()
            given(mock).execute().willReturn([])
            return mock
        }()
    ) -> SettingsViewModel {
        SettingsViewModel(
            languageInteractor: languageInteractor,
            modelInteractor: modelInteractor,
            modelsLister: modelsLister
        )
    }
}
