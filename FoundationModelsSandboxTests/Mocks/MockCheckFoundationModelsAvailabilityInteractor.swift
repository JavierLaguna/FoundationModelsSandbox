import Foundation
import FoundationModels
@testable import FoundationModelsSandbox

final class MockCheckFoundationModelsAvailabilityInteractor: CheckFoundationModelsAvailabilityInteractor, @unchecked Sendable {

    var executeResult: SystemLanguageModel.Availability = .unavailable(.deviceNotEligible)

    func execute(model: SystemLanguageModel?) -> SystemLanguageModel.Availability {
        executeResult
    }
}