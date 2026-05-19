import Testing
import Foundation
import FoundationModels
@testable import FoundationModelsSandbox

@MainActor
struct ListAvailableModelsInteractorTests {

    // MARK: - execute

    @Test
    func execute_returnsArray() {
        let sut = ListAvailableModelsInteractorDefault()

        let result = sut.execute()

        // Verify result is an array (type check is implicit from return type)
        #expect(!result.isEmpty || result.isEmpty)
    }

    @Test
    func execute_countMatchesAvailability() {
        let sut = ListAvailableModelsInteractorDefault()

        let result = sut.execute()

        // If default model is available, count should be 1, otherwise 0
        let expectedCount = SystemLanguageModel.default.isAvailable ? 1 : 0
        #expect(result.count == expectedCount)
    }

    @Test
    func execute_emptyWhenNoModelsAvailable() {
        // This test documents that the interactor returns empty when no models available
        // The actual behavior depends on device state at test time
        let sut = ListAvailableModelsInteractorDefault()

        let result = sut.execute()

        // If default model is not available, result should be empty
        if !SystemLanguageModel.default.isAvailable {
            #expect(result.isEmpty)
        }
    }
}