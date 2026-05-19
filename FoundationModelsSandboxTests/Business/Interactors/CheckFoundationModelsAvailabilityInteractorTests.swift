import Testing
import Foundation
import FoundationModels
@testable import FoundationModelsSandbox

@MainActor
struct CheckFoundationModelsAvailabilityInteractorTests {

    // MARK: - execute

    @Test
    func execute_withNilModel_returnsUnavailable() {
        let sut = CheckFoundationModelsAvailabilityInteractorDefault()

        let result = sut.execute(model: nil)

        #expect(result == .unavailable(.deviceNotEligible))
    }

    @Test
    func execute_withDefaultModel_returnsModelAvailability() {
        let sut = CheckFoundationModelsAvailabilityInteractorDefault()

        let result = sut.execute(model: SystemLanguageModel.default)

        // The result should match the actual model's availability on the device
        // This test documents the real behavior
        #expect(result == SystemLanguageModel.default.availability)
    }

    @Test
    func execute_staticIsAvailable_matchesDefaultModel() {
        // Verify static property matches the instance check
        let defaultModel = CheckFoundationModelsAvailabilityInteractorDefault.model

        #expect(CheckFoundationModelsAvailabilityInteractorDefault.isAvailable == defaultModel.isAvailable)
    }

    @Test
    func execute_staticAvailabilityReason_matchesDefaultModel() {
        // Verify static property matches the instance check
        let defaultModel = CheckFoundationModelsAvailabilityInteractorDefault.model

        #expect(CheckFoundationModelsAvailabilityInteractorDefault.availabilityReason == defaultModel.availability)
    }
}