import FoundationModels

protocol FoundationModelsInteractor: Sendable {
    func execute(prompt: String) async throws -> String
}


struct FoundationModelsInteractorDefault: FoundationModelsInteractor {

    private let session: LanguageModelSession
    private let availabilityChecker: CheckFoundationModelsAvailabilityInteractor

    init(
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault(),
        model: SystemLanguageModel = CheckFoundationModelsAvailabilityInteractorDefault.model
    ) {
        self.availabilityChecker = availabilityChecker
        self.session = LanguageModelSession(model: model)
    }

    func execute(prompt: String) async throws -> String {
        let reason = availabilityChecker.execute()
        guard CheckFoundationModelsAvailabilityInteractorDefault.isAvailable else {
            throw AppleIntelligenceNotAvailableError(from: reason)
        }

        let response = try await session.respond(
            to: prompt,
            options: GenerationOptions(
                sampling: .greedy
            )
        )

        return response.content
    }
}
