import Foundation
import SwiftUI

// MARK: - Main ViewModel
@Observable
@MainActor
final class MainViewModel {
    
    // MARK: - Dependencies
    private let interactor: FoundationModelsInteractor
    
    // MARK: - Navigation State
    var selectedSection: String = "Playground"
    
    // MARK: - Prompt State
    var systemPrompt: String = ""
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
    init(interactor: FoundationModelsInteractor = FoundationModelsInteractorDefault()) {
        self.interactor = interactor
    }
    
    // MARK: - Actions
    func submitPrompt() async {
        guard canSubmitPrompt else { return }
        
        isLoading = true
        error = nil
        
        do {
            aiResponse = try await interactor.execute(prompt: userPrompt)
            aiCode = extractCodeBlock(from: aiResponse)
            userPrompt = ""
            
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearPrompts() {
        systemPrompt = ""
        userPrompt = ""
        aiResponse = ""
        aiCode = ""
        error = nil
    }
    
    func selectSection(_ section: String) {
        selectedSection = section
    }
    
    // MARK: - Private Helpers
    
    private func extractCodeBlock(from response: String) -> String {
        // Simple extraction - look for code between ```
        let pattern = "```(?:\\w+)?\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)),
              let range = Range(match.range(at: 1), in: response) else {
            return ""
        }
        return String(response[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
