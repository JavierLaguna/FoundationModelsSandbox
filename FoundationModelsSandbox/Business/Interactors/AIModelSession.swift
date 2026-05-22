import Foundation
import FoundationModels
import Mockable

/// Lightweight response type that wraps the data extracted from a `LanguageModelSession.Response`.
/// It is fully constructable in tests, unlike the system framework's response type.
struct SessionResponse: Sendable, Equatable {
    let content: String
    let duration: Double
    let promptTokenCount: Int
    let responseTokenCount: Int
}

/// Protocol that wraps `LanguageModelSession.respond(to:options:)` so it can be mocked in tests.
@Mockable
protocol AIModelSession: Sendable {
    func respond(to prompt: Prompt, options: GenerationOptions) async throws -> SessionResponse
}

/// Default implementation that delegates to a real `LanguageModelSession`
/// and extracts metrics via reflection.
struct LiveModelSession: AIModelSession {
    private let session: LanguageModelSession

    init(model: SystemLanguageModel, instructions: String) {
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }

    func respond(to prompt: Prompt, options: GenerationOptions) async throws -> SessionResponse {
        let response = try await session.respond(to: prompt, options: options)
        return SessionResponse(
            content: response.content,
            duration: extractDuration(from: response),
            promptTokenCount: extractTokenCount(from: response, label: "promptTokenCount"),
            responseTokenCount: extractTokenCount(from: response, label: "responseTokenCount")
        )
    }
}

// MARK: - Mirror-based extraction (moved from FoundationModelsInteractorDefault)

private extension LiveModelSession {

    func extractDuration(from response: LanguageModelSession.Response<String>) -> Double {
        let mirror = Mirror(reflecting: response)
        for child in mirror.children where child.label == "duration" {
            return child.value as? Double ?? 0
        }
        return 0
    }

    func extractTokenCount(from response: LanguageModelSession.Response<String>, label: String) -> Int {
        let mirror = Mirror(reflecting: response)
        for child in mirror.children where child.label == label {
            if let intValue = child.value as? Int {
                return intValue
            }
            if let optional = child.value as? Int?, let unwrapped = optional {
                return unwrapped
            }
        }
        return 0
    }
}
