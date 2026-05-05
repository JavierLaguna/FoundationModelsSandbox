import FoundationModels

/// Checks the availability status of Foundation Models on the device.
protocol CheckFoundationModelsAvailabilityInteractor: Sendable {
    func execute() -> SystemLanguageModel.Availability
}

struct CheckFoundationModelsAvailabilityInteractorDefault: CheckFoundationModelsAvailabilityInteractor {

    public static let model = SystemLanguageModel.default

    public static var isAvailable: Bool {
        Self.model.isAvailable
    }

    public static var availabilityReason: SystemLanguageModel.Availability {
        Self.model.availability
    }

    public init() {}

    public func execute() -> SystemLanguageModel.Availability {
        Self.availabilityReason
    }
}
