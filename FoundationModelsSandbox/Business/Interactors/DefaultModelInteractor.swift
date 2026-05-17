import Foundation
import FoundationModels

/// Handles default model preference persistence
protocol DefaultModelInteractor: Sendable {
    func getDefaultModelName() -> String
    func setDefaultModelName(_ name: String)
    func getAvailableModels() -> [SystemLanguageModel]
}

final class DefaultModelInteractorDefault: DefaultModelInteractor {

    private let userDefaults: UserDefaults
    private let modelsLister: ListAvailableModelsInteractor

    init(
        userDefaults: UserDefaults = .standard,
        modelsLister: ListAvailableModelsInteractor = ListAvailableModelsInteractorDefault()
    ) {
        self.userDefaults = userDefaults
        self.modelsLister = modelsLister
    }

    func getDefaultModelName() -> String {
        userDefaults.string(forKey: UserDefaultsKeys.defaultModelPreference) ?? "default"
    }

    func setDefaultModelName(_ name: String) {
        userDefaults.set(name, forKey: UserDefaultsKeys.defaultModelPreference)
    }

    func getAvailableModels() -> [SystemLanguageModel] {
        modelsLister.execute()
    }
}