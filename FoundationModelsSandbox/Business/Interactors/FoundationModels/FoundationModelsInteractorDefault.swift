import Foundation
import FoundationModels

@MainActor
final class FoundationModelsInteractorDefault: FoundationModelsInteractor {

    // MARK: - Dependencies
    private let availabilityChecker: CheckFoundationModelsAvailabilityInteractor
    private let defaultModel: SystemLanguageModel
    private let sessionProvider: SessionProvider
    private let truncationStrategyFactory: (ContextTruncationStrategy) -> ContextTruncationStrategyHandler

    // MARK: - State
    private var activeSession: AIModelSession?
    private var truncationHandler: ContextTruncationStrategyHandler
    private var activeModel: SystemLanguageModel?

    var hasActiveConversation: Bool {
        activeSession != nil
    }

    var contextSize: Int {
        activeModel?.contextSize ?? defaultModel.contextSize
    }

    // MARK: - Init

    init(
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault(),
        model: SystemLanguageModel = CheckFoundationModelsAvailabilityInteractorDefault.model,
        sessionProvider: SessionProvider = LiveSessionProvider(),
        truncationStrategyFactory: @escaping (ContextTruncationStrategy) -> ContextTruncationStrategyHandler = { strategy in
            switch strategy {
            case .dropOldest:
                DropOldestStrategy()
            case .summarize:
                SummarizeStrategy()
            }
        }
    ) {
        self.availabilityChecker = availabilityChecker
        self.defaultModel = model
        self.sessionProvider = sessionProvider
        self.truncationStrategyFactory = truncationStrategyFactory
        self.truncationHandler = truncationStrategyFactory(.dropOldest)
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
        truncationHandler = truncationStrategyFactory(truncationStrategy)

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

    func updateTruncationStrategy(_ strategy: ContextTruncationStrategy) {
        truncationHandler = truncationStrategyFactory(strategy)
    }
}

// MARK: - Private methods

private extension FoundationModelsInteractorDefault {

    /// Attempts to free context by delegating to the current truncation handler.
    /// After truncation, the active session is replaced with a new one using the trimmed transcript.
    func handleContextOverflow() async throws {
        guard let session = activeSession, let model = activeModel else { return }

        let newTranscript = try await truncationHandler.truncateTranscript(
            session.transcript,
            model: model,
            sessionProvider: sessionProvider
        )

        activeSession = sessionProvider.makeSession(model: model, transcript: newTranscript)
    }
}
