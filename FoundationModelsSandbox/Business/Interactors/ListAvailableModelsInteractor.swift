import FoundationModels
import Mockable

/// Lists the available Foundation Models on the device.
@Mockable
protocol ListAvailableModelsInteractor: Sendable {
    func execute() -> [SystemLanguageModel]
}

struct ListAvailableModelsInteractorDefault: ListAvailableModelsInteractor {

    func execute() -> [SystemLanguageModel] {
        var models: [SystemLanguageModel] = []

        let defaultModel = SystemLanguageModel.default
        if defaultModel.isAvailable {
            models.append(defaultModel)
        }

        return models
    }
}
