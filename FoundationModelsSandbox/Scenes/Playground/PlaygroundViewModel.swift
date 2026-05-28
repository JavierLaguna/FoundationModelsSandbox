import Foundation
import FoundationModels
import SwiftUI

// MARK: - Playground ViewModel
@Observable
@MainActor
final class PlaygroundViewModel {

    // MARK: - Dependencies
    private let interactor: FoundationModelsInteractor
    private let availabilityChecker: CheckFoundationModelsAvailabilityInteractor
    private let modelsLister: ListAvailableModelsInteractor
    private let clipboard: ClipboardInteractor
    private let defaultModelInteractor: DefaultModelInteractor
    private let sessionRepository: any SessionRepository

    // MARK: - Availability State
    private(set) var isFoundationModelsAvailable: Bool = false
    private(set) var availabilityReason: SystemLanguageModel.Availability?

    // MARK: - Instructions State
    var instructions: String = "" {
        didSet { session.instructions = instructions }
    }
    var userPrompt: String = ""
    var selectedModelName: String = ""

    // MARK: - Response State
    var aiResponse: AIResponse?
    var isLoading: Bool = false
    var error: String?

    // MARK: - Session State
    private(set) var session: ConversationSession

    // MARK: - Copy State
    var isCodeCopied: Bool = false

    // MARK: - Available Models
    private(set) var availableModelNames: [String] = []
    private(set) var availableModels: [SystemLanguageModel] = []
    private(set) var selectedModel: SystemLanguageModel?

    // MARK: - Computed Properties
    var canSubmitPrompt: Bool {
        !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && !selectedModelName.isEmpty
    }

    var hasResponse: Bool {
        aiResponse?.content.isEmpty == false
    }

    /// Convenience accessor for response content
    var responseContent: String {
        aiResponse?.content ?? ""
    }

    /// Convenience accessor for extracted code
    var responseCode: String {
        guard let response = aiResponse else { return "" }
        return extractCodeBlock(from: response.content)
    }

    /// Convenience accessor for metrics footer
    var metricsFooter: String {
        guard let response = aiResponse else { return "" }
        return "\(response.formattedDuration) • \(response.formattedTokenCounts)"
    }

    // MARK: - Initialization
    init(
        interactor: FoundationModelsInteractor = FoundationModelsInteractorDefault(),
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault(),
        modelsLister: ListAvailableModelsInteractor = ListAvailableModelsInteractorDefault(),
        clipboard: ClipboardInteractor = ClipboardInteractorDefault(),
        defaultModelInteractor: DefaultModelInteractor = DefaultModelInteractorDefault(),
        sessionRepository: any SessionRepository = LiveSessionRepository.makeDefault(),
        shouldRestoreLastSession: Bool = true
    ) {
        self.interactor = interactor
        self.availabilityChecker = availabilityChecker
        self.modelsLister = modelsLister
        self.clipboard = clipboard
        self.defaultModelInteractor = defaultModelInteractor
        self.sessionRepository = sessionRepository
        self.session = ConversationSession()

        loadModels()
        checkAvailability()

        // Restore the last session from disk without blocking init.
        // Pass `false` for "New Chat" to start with a clean session.
        if shouldRestoreLastSession {
            restoreLastSession()
        }
    }

    // MARK: - Actions
    private func loadModels() {
        let models = modelsLister.execute()
        // Use "default" as the display name for SystemLanguageModel
        availableModels = models
        availableModelNames = models.isEmpty ? [] : ["default"]

        // Use the default model from UserDefaults
        let defaultModelName = defaultModelInteractor.getDefaultModelName()
        selectedModelName = availableModelNames.contains(defaultModelName) ? defaultModelName : (availableModelNames.first ?? "")
        selectedModel = models.first

        // Initialize session with the selected model
        session.modelName = selectedModelName
    }

    private func checkAvailability() {
        let reason = availabilityChecker.execute(model: selectedModel)
        availabilityReason = reason
        isFoundationModelsAvailable = selectedModel?.isAvailable ?? false
    }

    /// Restores the most recent session from the repository, if any.
    private func restoreLastSession() {
        guard let last = try? sessionRepository.lastSession() else { return }
        loadSession(last)
    }

    /// Loads a specific session into the ViewModel.
    func loadSession(_ session: ConversationSession) {
        self.session = session
        instructions = session.instructions
        if !session.modelName.isEmpty {
            selectedModelName = session.modelName
        }
        if case .success(let response) = session.latestResponse {
            aiResponse = response
        }
    }

    func modelSelectionChanged(to modelName: String) {
        selectedModelName = modelName
        // Find the corresponding model - since we only have "default" as name,
        // we use the first available model
        selectedModel = availableModels.first
        // Re-check availability for the newly selected model
        checkAvailability()
        // Update session with new model name
        session.modelName = modelName
    }

    func updateInstructions(_ newInstructions: String) {
        instructions = newInstructions
        session.instructions = newInstructions
    }

    func submitPrompt() async {
        guard canSubmitPrompt else { return }

        isLoading = true
        error = nil

        let prompt = userPrompt
        userPrompt = ""

        let messageId = session.addMessage(prompt: prompt, outcome: .noResponse)
        // Persist immediately so the prompt is saved even if the response fails.
        try? sessionRepository.saveSession(session)

        do {
            let response = try await interactor.execute(
                prompt: prompt,
                instructions: instructions
            )

            aiResponse = response
            session.updateMessage(id: messageId, outcome: .success(response))

        } catch {
            let errorMessage = error.localizedDescription
            self.error = errorMessage
            session.updateMessage(id: messageId, outcome: .failure(errorMessage))
        }
        isLoading = false

        // Persist the updated session with the response.
        try? sessionRepository.saveSession(session)
    }

    func clearPrompts() {
        // Save the current session to disk before clearing.
        let oldSession = session
        Task { [weak self] in
            try? self?.sessionRepository.saveSession(oldSession)
        }

        instructions = ""
        userPrompt = ""
        aiResponse = nil
        error = nil
        session = ConversationSession(modelName: selectedModelName, instructions: "")
    }

    func copyMessageToClipboard(_ message: MessageEntry) {
        guard case .success(let response) = message.outcome, !response.content.isEmpty else { return }

        clipboard.copy(response.content)
    }

    func copyCodeToClipboard() {
        guard !responseCode.isEmpty else { return }

        clipboard.copy(responseCode)

        isCodeCopied = true

        // Reset the copied state after 2 seconds
        Task {
            try? await Task.sleep(for: .seconds(2))
            isCodeCopied = false
        }
    }

    // MARK: - Private Helpers

    private func extractCodeBlock(from response: String) -> String {
        let pattern = "```(?:\\w+)?\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)),
              let range = Range(match.range(at: 1), in: response) else {
            return ""
        }
        return String(response[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
