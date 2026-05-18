import Testing
@testable import FoundationModelsSandbox
import FoundationModels

@MainActor
struct AppleIntelligenceNotAvailableErrorTests {

    // MARK: - Error Cases

    @Test
    func errorDescription_deviceNotEligible_returnsLocalizedString() {
        let error = AppleIntelligenceNotAvailableError.deviceNotEligible

        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test
    func errorDescription_appleIntelligenceNotEnabled_returnsLocalizedString() {
        let error = AppleIntelligenceNotAvailableError.appleIntelligenceNotEnabled

        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test
    func errorDescription_modelNotReady_returnsLocalizedString() {
        let error = AppleIntelligenceNotAvailableError.modelNotReady

        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test
    func errorDescription_other_withReason_returnsLocalizedString() {
        let error = AppleIntelligenceNotAvailableError.other("Test reason")

        #expect(error.errorDescription?.contains("Test reason") == true)
    }

    // MARK: - Init from SystemLanguageModel.Availability

    @Test
    func init_fromAvailability_available_returnsOtherError() {
        let availability: SystemLanguageModel.Availability = .available

        let error = AppleIntelligenceNotAvailableError(from: availability)

        var isOtherCase = false
        var message = ""
        if case .other(let msg) = error {
            isOtherCase = true
            message = msg
        }
        #expect(isOtherCase)
        #expect(message == "WTF this feature is available!")
    }

    @Test
    func init_fromAvailability_unavailableDeviceNotEligible_returnsDeviceNotEligible() {
        let availability: SystemLanguageModel.Availability = .unavailable(.deviceNotEligible)

        let error = AppleIntelligenceNotAvailableError(from: availability)

        var isDeviceNotEligible = false
        if case .deviceNotEligible = error {
            isDeviceNotEligible = true
        }
        #expect(isDeviceNotEligible)
    }

    @Test
    func init_fromAvailability_unavailableAppleIntelligenceNotEnabled_returnsAppleIntelligenceNotEnabled() {
        let availability: SystemLanguageModel.Availability = .unavailable(.appleIntelligenceNotEnabled)

        let error = AppleIntelligenceNotAvailableError(from: availability)

        var isAppleIntelligenceNotEnabled = false
        if case .appleIntelligenceNotEnabled = error {
            isAppleIntelligenceNotEnabled = true
        }
        #expect(isAppleIntelligenceNotEnabled)
    }

    @Test
    func init_fromAvailability_unavailableModelNotReady_returnsModelNotReady() {
        let availability: SystemLanguageModel.Availability = .unavailable(.modelNotReady)

        let error = AppleIntelligenceNotAvailableError(from: availability)

        var isModelNotReady = false
        if case .modelNotReady = error {
            isModelNotReady = true
        }
        #expect(isModelNotReady)
    }

    @Test
    func init_fromAvailability_unavailableModelNotReady_doesNotReturnOther() {
        let availability: SystemLanguageModel.Availability = .unavailable(.modelNotReady)

        let error = AppleIntelligenceNotAvailableError(from: availability)

        var isOtherCase = false
        if case .other = error {
            isOtherCase = true
        }
        // .unavailable(.modelNotReady) maps to .modelNotReady, not .other
        #expect(!isOtherCase)
    }

    // NOTE: The catch-all case `.unavailable(let other)` in init(from:)
    // is not tested here because `SystemLanguageModel.Availability.UnavailableReason`
    // is from the FoundationModels module, and we cannot construct "unknown" reason values.
}