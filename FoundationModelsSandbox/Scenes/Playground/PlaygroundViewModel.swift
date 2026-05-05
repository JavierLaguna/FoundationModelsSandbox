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
    private(set) var aiResponse: String = ""
    private(set) var aiCode: String = ""
    var isLoading: Bool = false
    private(set) var error: String?
    
    // MARK: - Available Models
    private(set) var availableModelNames: [String] = []
    
    // MARK: - Computed Properties
    var canSubmitPrompt: Bool {
        !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && !selectedModelName.isEmpty
    }
    
    var hasResponse: Bool {
        !aiResponse.isEmpty
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
        availableModelNames = models.isEmpty ? [] : ["default"]
        selectedModelName = availableModelNames.first ?? ""
    }
    
    private func checkAvailability() {
        let reason = availabilityChecker.execute()
        availabilityReason = reason
        isFoundationModelsAvailable = CheckFoundationModelsAvailabilityInteractorDefault.isAvailable
    }
    
    func submitPrompt() async {
        guard canSubmitPrompt else { return }
        
        isLoading = true
        error = nil
        
        let fullPrompt = buildPrompt()
        
        do {
            aiResponse = try await interactor.execute(prompt: fullPrompt)
            aiCode = extractCodeBlock(from: aiResponse)
            userPrompt = ""
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearPrompts() {
        instructions = ""
        userPrompt = ""
        aiResponse = ""
        aiCode = ""
        error = nil
    }
    
    // MARK: - Private Helpers
    
    private func buildPrompt() -> String {
        if instructions.isEmpty {
            return userPrompt
        }
        return "Instructions: \(instructions)\n\nUser: \(userPrompt)"
    }
    
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