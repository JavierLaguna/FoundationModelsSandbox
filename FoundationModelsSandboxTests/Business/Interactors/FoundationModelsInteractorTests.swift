import Testing
import Foundation
import FoundationModels
import Mockable
@testable import FoundationModelsSandbox

@MainActor
struct FoundationModelsInteractorTests {

    init() {
        MockerPolicy.default = .relaxed
    }

    // MARK: - execute

    // Note: Full testing of FoundationModelsInteractor is limited because:
    // - SystemLanguageModel comes from FoundationModels package and cannot be mocked
    // - The actual model availability depends on device state
    // - Testing the "unavailable" path requires mocking both availabilityChecker AND model.isAvailable
    //
    // The error path is tested via integration tests or manual testing with unavailable models.
    // The success path requires a real available model on the device.

    // MARK: - Test Fixtures

    private static var sampleModel: SystemLanguageModel {
        SystemLanguageModel.default
    }
}