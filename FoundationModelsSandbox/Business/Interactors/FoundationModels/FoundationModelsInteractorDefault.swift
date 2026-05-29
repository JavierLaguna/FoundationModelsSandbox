import Foundation
import FoundationModels

@MainActor
final class FoundationModelsInteractorDefault: FoundationModelsInteractor {

    // MARK: - Dependencies
    private let availabilityChecker: CheckFoundationModelsAvailabilityInteractor
    private let defaultModel: SystemLanguageModel
    private let sessionProvider: SessionProvider

    // MARK: - State
    private var activeSession: AIModelSession?
    private var truncationStrategy: ContextTruncationStrategy = .dropOldest
    private var activeModel: SystemLanguageModel?

    // MARK: - Init

    init(
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault(),
        model: SystemLanguageModel = CheckFoundationModelsAvailabilityInteractorDefault.model,
        sessionProvider: SessionProvider = LiveSessionProvider()
    ) {
        self.availabilityChecker = availabilityChecker
        self.defaultModel = model
        self.sessionProvider = sessionProvider
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
            activeSession = sessionProvider.makeSession(model: model, transcript: transcript)
        } else {
            activeSession = sessionProvider.makeSession(model: model, instructions: instructions)
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

    func updateTruncationStrategy(_ strategy: ContextTruncationStrategy) {
        truncationStrategy = strategy
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
        let entries = Array(currentTranscript)

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
        activeSession = sessionProvider.makeSession(model: model, transcript: trimmedTranscript)
    }
}
