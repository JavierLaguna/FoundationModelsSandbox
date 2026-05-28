import Foundation
import FoundationModels
import Mockable

/// Errors that can occur during a conversation session.
enum FoundationModelsInteractorError: Error, LocalizedError, Equatable {
    case noActiveConversation
    case contextOverflow

    var errorDescription: String? {
        switch self {
        case .noActiveConversation:
            String(localized: "No active conversation. Start a new conversation first.")
        case .contextOverflow:
            String(localized: "The conversation context is full. Try clearing some messages.")
        }
    }
}

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

final class FoundationModelsInteractorDefault: FoundationModelsInteractor, @unchecked Sendable {

    // MARK: - Dependencies
    private let availabilityChecker: CheckFoundationModelsAvailabilityInteractor
    private let defaultModel: SystemLanguageModel
    private let sessionFactory: (SystemLanguageModel, String) -> AIModelSession

    // MARK: - State
    private var activeSession: AIModelSession?
    private var truncationStrategy: ContextTruncationStrategy = .dropOldest
    private var activeModel: SystemLanguageModel?

    // MARK: - Init

    init(
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault(),
        model: SystemLanguageModel = CheckFoundationModelsAvailabilityInteractorDefault.model,
        sessionFactory: @escaping (SystemLanguageModel, String) -> AIModelSession = { model, instructions in
            LiveModelSession(model: model, instructions: instructions)
        }
    ) {
        self.availabilityChecker = availabilityChecker
        self.defaultModel = model
        self.sessionFactory = sessionFactory
    }

    // MARK: - FoundationModelsInteractor

    func startConversation(
        model: SystemLanguageModel,
        instructions: String,
        truncationStrategy: ContextTruncationStrategy,
        transcript: Transcript? = nil
    ) async throws {
        let reason = availabilityChecker.execute(model: model)
        guard case .available = reason else {
            throw AppleIntelligenceNotAvailableError(from: reason)
        }

        activeModel = model
        self.truncationStrategy = truncationStrategy

        if let transcript {
            activeSession = LiveModelSession(model: model, transcript: transcript)
        } else {
            activeSession = sessionFactory(model, instructions)
        }
    }

    func sendMessage(_ prompt: String) async throws -> AIResponse {
        guard let session = activeSession, let model = activeModel else {
            throw FoundationModelsInteractorError.noActiveConversation
        }

        do {
            let response = try await session.respond(
                to: Prompt(prompt),
                options: GenerationOptions(sampling: .greedy)
            )

            return AIResponse(
                content: response.content,
                duration: response.duration,
                promptTokenCount: response.promptTokenCount,
                responseTokenCount: response.responseTokenCount,
                contextSize: model.contextSize
            )
        } catch let error as LanguageModelSession.GenerationError {
            if case .exceededContextWindowSize = error {
                try await handleContextOverflow()
                // Retry after truncation
                return try await sendMessage(prompt)
            }
            throw error
        }
    }

    func currentTranscript() async -> Transcript? {
        activeSession?.transcript
    }

    func endConversation() {
        activeSession = nil
        activeModel = nil
    }

    var hasActiveConversation: Bool {
        activeSession != nil
    }

    var contextSize: Int {
        activeModel?.contextSize ?? defaultModel.contextSize
    }

    // MARK: - Context Management

    /// Attempts to free context by truncating the transcript according to the current strategy.
    /// After truncation, the active session is replaced with a new one using the trimmed transcript.
    private func handleContextOverflow() async throws {
        switch truncationStrategy {
        case .dropOldest:
            try await applyDropOldest()
        case .manual:
            throw FoundationModelsInteractorError.contextOverflow
        case .summarize:
            // Not yet implemented
            throw FoundationModelsInteractorError.contextOverflow
        }
    }

    private func applyDropOldest() async throws {
        guard let session = activeSession, let model = activeModel else { return }

        let currentTranscript = session.transcript
        var entries = Array(currentTranscript)

        // Always keep instructions entry (usually the first one)
        let instructionsEntries = entries.filter { entry in
            if case .instructions = entry { return true }
            return false
        }

        // Drop oldest prompt+response pairs, keep the most recent ones
        let nonInstructionEntries = entries.filter { entry in
            if case .instructions = entry { return false }
            return true
        }

        // Drop half of the non-instruction entries (oldest first)
        let entriesToKeep = nonInstructionEntries.suffix(nonInstructionEntries.count / 2)
        let trimmedEntries = instructionsEntries + entriesToKeep

        let trimmedTranscript = Transcript(entries: trimmedEntries)

        // Replace the session with one using the trimmed transcript
        activeSession = LiveModelSession(model: model, transcript: trimmedTranscript)
    }
}
