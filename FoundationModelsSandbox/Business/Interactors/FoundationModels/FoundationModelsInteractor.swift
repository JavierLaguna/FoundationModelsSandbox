import Foundation
import FoundationModels
import Mockable

@Mockable
protocol FoundationModelsInteractor: Sendable {
    /// Starts a new conversation with the given model and instructions.
    /// - Parameter transcript: Optional transcript to restore a previous conversation.
    func startConversation(
        model: SystemLanguageModel,
        instructions: String,
        truncationStrategy: ContextTruncationStrategy,
        transcript: Transcript?
    ) async throws

    /// Starts a new conversation without a transcript.
    func startConversation(
        model: SystemLanguageModel,
        instructions: String,
        truncationStrategy: ContextTruncationStrategy
    ) async throws

    /// Sends a prompt to the active conversation and returns the response.
    /// - Throws: `FoundationModelsInteractorError.noActiveConversation` if no session is active.
    /// - Throws: `FoundationModelsInteractorError.contextOverflow` if context is full and strategy is `.manual`.
    func sendMessage(_ prompt: String) async throws -> AIResponse

    /// Returns the current transcript for serialization.
    func currentTranscript() async -> Transcript?

    /// Ends the active conversation.
    func endConversation()

    /// Whether a conversation session is active.
    var hasActiveConversation: Bool { get }

    /// The maximum context size (token limit) for the current model.
    var contextSize: Int { get }

    /// Updates the truncation strategy for the active conversation.
    func updateTruncationStrategy(_ strategy: ContextTruncationStrategy)
}

// MARK: - Protocol extension for convenience overload without transcript

extension FoundationModelsInteractor {
    func startConversation(
        model: SystemLanguageModel,
        instructions: String,
        truncationStrategy: ContextTruncationStrategy
    ) async throws {
        try await startConversation(
            model: model,
            instructions: instructions,
            truncationStrategy: truncationStrategy,
            transcript: nil
        )
    }
}
