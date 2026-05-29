import Foundation
import FoundationModels
import Mockable

/// Protocol that wraps `LanguageModelSession` so it can be mocked in tests.
@Mockable
protocol AIModelSession: Sendable {
    func respond(to prompt: Prompt, options: GenerationOptions) async throws -> SessionResponse
    var transcript: Transcript { get }
}

/// Default implementation that delegates to a real `LanguageModelSession`
/// and extracts metrics via reflection.
final class LiveModelSession: AIModelSession {
    
    private let session: LanguageModelSession

    init(model: SystemLanguageModel, instructions: String) {
        self.session = LanguageModelSession(
            model: model,
            instructions: instructions
        )
    }

    /// Creates a session from an existing transcript (for restoration or truncation).
    init(model: SystemLanguageModel, transcript: Transcript) {
        self.session = LanguageModelSession(
            model: model,
            transcript: transcript
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

    var transcript: Transcript {
        session.transcript
    }
}

// MARK: - Mirror-based extraction

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
