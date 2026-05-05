import FoundationModels

/// Lists the available Foundation Models on the device.
protocol ListAvailableModelsInteractor: Sendable {
    func execute() -> [SystemLanguageModel]
}

struct ListAvailableModelsInteractorDefault: ListAvailableModelsInteractor {
    
    public init() {}
    
    public func execute() -> [SystemLanguageModel] {
        // Get available models from the system
        var models: [SystemLanguageModel] = []
        
        // Find all models that are available on the device
        if #available(macOS 26.0, *) {
            // Use the default model as reference and check availability
            let defaultModel = SystemLanguageModel.default
            if defaultModel.isAvailable {
                models.append(defaultModel)
            }
        }
        
        return models
    }
}
