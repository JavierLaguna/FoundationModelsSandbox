import Foundation
import FoundationModels
@testable import FoundationModelsSandbox

final class MockFoundationModelsInteractor: FoundationModelsInteractor, @unchecked Sendable {

    var executeResult: AIResponse?
    var executeError: Error?

    func execute(prompt: String, instructions: String) async throws -> AIResponse {
        if let error = executeError {
            throw error
        }
        guard let result = executeResult else {
            throw NSError(domain: "Mock", code: -1, userInfo: [NSLocalizedDescriptionKey: "No result set"])
        }
        return result
    }
}