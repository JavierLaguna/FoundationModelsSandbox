import FoundationModels

protocol FoundationModelsInteractor: Sendable {
    func execute(prompt: String, instructions: String) async throws -> String
}

struct FoundationModelsInteractorDefault: FoundationModelsInteractor {

    private let model: SystemLanguageModel
    private let availabilityChecker: CheckFoundationModelsAvailabilityInteractor

    init(
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault(),
        model: SystemLanguageModel = CheckFoundationModelsAvailabilityInteractorDefault.model
    ) {
        self.availabilityChecker = availabilityChecker
        self.model = model
    }

    func execute(prompt: String, instructions: String) async throws -> String {
        let reason = availabilityChecker.execute(model: model)
        guard model.isAvailable else {
            throw AppleIntelligenceNotAvailableError(from: reason)
        }
        
        let session = LanguageModelSession(
            model: model,
            instructions: instructions
        )

        let response = try await session.respond(
            to: Prompt(prompt),
            options: GenerationOptions(
                sampling: .greedy
            )
        )

        return response.content
    }
}
