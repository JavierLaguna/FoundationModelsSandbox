import Foundation
import FoundationModels

protocol FoundationModelsInteractor: Sendable {
    func execute(prompt: String, instructions: String) async throws -> AIResponse
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
    
    func execute(prompt: String, instructions: String) async throws -> AIResponse {
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
        
        let contextSize = model.contextSize
        let metrics = extractMetrics(from: response)
        
        return AIResponse(
            content: response.content,
            duration: metrics.duration,
            promptTokenCount: metrics.promptTokenCount,
            responseTokenCount: metrics.responseTokenCount,
            contextSize: contextSize
        )
    }
}

// MARK: - Private Extension
private extension FoundationModelsInteractorDefault {
    
    struct Metrics {
        var duration: Double = 0
        var promptTokenCount: Int = 0
        var responseTokenCount: Int = 0
    }
    
    func extractMetrics(from response: LanguageModelSession.Response<String>) -> Metrics {
        var metrics = Metrics()
        let mirror = Mirror(reflecting: response)
        
        for child in mirror.children {
            guard let label = child.label else { continue }
            
            switch label {
            case "duration":
                metrics.duration = child.value as? Double ?? 0
            case "promptTokenCount":
                metrics.promptTokenCount = extractOptionalInt(from: child.value)
            case "responseTokenCount":
                metrics.responseTokenCount = extractOptionalInt(from: child.value)
            default:
                break
            }
        }
        
        return metrics
    }
    
    func extractOptionalInt(from value: Any) -> Int {
        if let intValue = value as? Int {
            return intValue
        }
        if let optional = value as? Int?, let unwrapped = optional {
            return unwrapped
        }
        return 0
    }
}
