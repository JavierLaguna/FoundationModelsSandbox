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
    
    // MARK: - Availability State
    private(set) var isFoundationModelsAvailable: Bool = false
    private(set) var availabilityReason: SystemLanguageModel.Availability?
    
    // MARK: - Navigation State
    var selectedSection: String = "Playground"
    
    // MARK: - Instructions State
    var instructions: String = ""
    var userPrompt: String = ""
    var selectedModel: String = "GPT-4-TURBO"
    
    // MARK: - Response State
    private(set) var aiResponse: String = ""
    private(set) var aiCode: String = ""
    var isLoading: Bool = false
    private(set) var error: String?
    
    // MARK: - Available Models
    let availableModels: [String] = [
        "GPT-4-TURBO",
        "GPT-4",
        "GPT-3.5-TURBO",
        "Claude 3 Opus"
    ]
    
    // MARK: - Computed Properties
    var canSubmitPrompt: Bool {
        !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    var hasResponse: Bool {
        !aiResponse.isEmpty
    }
    
    // MARK: - Initialization
    init(
        interactor: FoundationModelsInteractor = FoundationModelsInteractorDefault(),
        availabilityChecker: CheckFoundationModelsAvailabilityInteractor = CheckFoundationModelsAvailabilityInteractorDefault()
    ) {
        self.interactor = interactor
        self.availabilityChecker = availabilityChecker
        checkAvailability()
    }
    
    // MARK: - Actions
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