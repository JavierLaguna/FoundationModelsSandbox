import FoundationModels

protocol FoundationModelsInteractor: Sendable {
    func execute(prompt: String) async throws -> String
}


struct FoundationModelsInteractorDefault: FoundationModelsInteractor {

    static private let model = SystemLanguageModel.default
    static private let instructions = ""

    static var isAvailable: Bool {
        Self.model.isAvailable
    }

    static var availabilityReason: SystemLanguageModel.Availability {
        Self.model.availability
    }

    private let session: LanguageModelSession

    init() {
        self.session = LanguageModelSession(
            model: Self.model,
//            instructions: Self.instructions
        )
    }

    func execute(prompt: String) async throws -> String {
        guard Self.isAvailable else {
            throw AppleIntelligenceNotAvailableError(from: Self.availabilityReason)
        }

        let response = try await session.respond(
            to: prompt,
//            generating: CharacterDescription.self,
            options: GenerationOptions(
                sampling: .greedy
            )
        )

        return response.content
    }
}
