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

    // MARK: - Availability State
    private(set) var isFoundationModelsAvailable: Bool = false
    private(set) var availabilityReason: SystemLanguageModel.Availability?

    // MARK: - Instructions State
    var instructions: String = ""
    var userPrompt: String = ""
    var selectedModelName: String = ""

    // MARK: - Response State
    private(set) var aiResponse: AIResponse?
    var isLoading: Bool = false
    private(set) var error: String?

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
        modelsLister: ListAvailableModelsInteractor = ListAvailableModelsInteractorDefault()
    ) {
        self.interactor = interactor
        self.availabilityChecker = availabilityChecker
        self.modelsLister = modelsLister
        loadModels()
        checkAvailability()
    }

    // MARK: - Actions
    private func loadModels() {
        let models = modelsLister.execute()
        // Use "default" as the display name for SystemLanguageModel
        availableModels = models
        availableModelNames = models.isEmpty ? [] : ["default"]
        selectedModelName = availableModelNames.first ?? ""
        selectedModel = models.first
    }

    private func checkAvailability() {
        let reason = availabilityChecker.execute(model: selectedModel)
        availabilityReason = reason
        isFoundationModelsAvailable = selectedModel?.isAvailable ?? false
    }

    func modelSelectionChanged(to modelName: String) {
        selectedModelName = modelName
        // Find the corresponding model - since we only have "default" as name,
        // we use the first available model
        selectedModel = availableModels.first
        // Re-check availability for the newly selected model
        checkAvailability()
    }

    func submitPrompt() async {
        guard canSubmitPrompt else { return }

        isLoading = true
        error = nil

        do {
            let response = try await interactor.execute(prompt: userPrompt, instructions: instructions)
            aiResponse = response
            userPrompt = ""

        } catch {
            self.error = error.localizedDescription
        }

        isLoading = false
    }

    func clearPrompts() {
        instructions = ""
        userPrompt = ""
        aiResponse = nil
        error = nil
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