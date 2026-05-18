import Foundation
import FoundationModels
@testable import FoundationModelsSandbox

final class MockListAvailableModelsInteractor: ListAvailableModelsInteractor, @unchecked Sendable {

    var executeResult: [SystemLanguageModel] = []

    func execute() -> [SystemLanguageModel] {
        executeResult
    }
}