import FoundationModels

/// Checks the availability status of Foundation Models on the device.
protocol CheckFoundationModelsAvailabilityInteractor: Sendable {
    func execute() -> SystemLanguageModel.Availability
}

struct CheckFoundationModelsAvailabilityInteractorDefault: CheckFoundationModelsAvailabilityInteractor {

    static let model = SystemLanguageModel.default

    static var isAvailable: Bool {
        Self.model.isAvailable
    }

    static var availabilityReason: SystemLanguageModel.Availability {
        Self.model.availability
    }

    func execute() -> SystemLanguageModel.Availability {
        Self.availabilityReason
    }
}