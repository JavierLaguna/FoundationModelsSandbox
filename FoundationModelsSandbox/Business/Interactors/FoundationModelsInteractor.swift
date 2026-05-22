import Foundation
import FoundationModels
import Mockable

@Mockable
protocol FoundationModelsInteractor: Sendable {
    func execute(prompt: String, instructions: String) async throws -> AIResponse
}

struct FoundationModelsInteractorDefault: FoundationModelsInteractor {
    
    private let model: SystemLanguageModel
    private let availabilityChecker: CheckFoundationModelsAvailabilityInteractor
    private let sessionFactory: (SystemLanguageModel, String) -> AIModelSession
    
    init(
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault(),
        model: SystemLanguageModel = CheckFoundationModelsAvailabilityInteractorDefault.model,
        sessionFactory: @escaping (SystemLanguageModel, String) -> AIModelSession = { model, instructions in
            LiveModelSession(model: model, instructions: instructions)
        }
    ) {
        self.availabilityChecker = availabilityChecker
        self.model = model
        self.sessionFactory = sessionFactory
    }
    
    func execute(prompt: String, instructions: String) async throws -> AIResponse {
        let reason = availabilityChecker.execute(model: model)
        guard case .available = reason else {
            throw AppleIntelligenceNotAvailableError(from: reason)
        }
        
        let session = sessionFactory(model, instructions)
        
        let response = try await session.respond(
            to: Prompt(prompt),
            options: GenerationOptions(
                sampling: .greedy
            )
        )
        
        return AIResponse(
            content: response.content,
            duration: response.duration,
            promptTokenCount: response.promptTokenCount,
            responseTokenCount: response.responseTokenCount,
            contextSize: model.contextSize
        )
    }
}
