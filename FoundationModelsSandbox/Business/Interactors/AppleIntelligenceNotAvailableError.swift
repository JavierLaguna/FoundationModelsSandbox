import Foundation
import FoundationModels

enum AppleIntelligenceNotAvailableError: Error, LocalizedError {
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case other(String)

    var errorDescription: String? {
        switch self {
        case .deviceNotEligible:
            "Your device is not eligible to use this feature."
        case .appleIntelligenceNotEnabled:
            "Please enable Apple Intelligence to access this feature."
        case .modelNotReady:
            "Model isn't ready yet. It may be downloading or initializing. Please try again later."
        case .other(let reason):
            "Model unavailable. Reason: \(reason)"
        }
    }
    
    init(from: SystemLanguageModel.Availability) {
        switch from {
        case .available:
            self = .other("WTF this feature is available!")
        case .unavailable(.deviceNotEligible):
            self = .deviceNotEligible
        case .unavailable(.appleIntelligenceNotEnabled):
            self = .appleIntelligenceNotEnabled
        case .unavailable(.modelNotReady):
            self = .modelNotReady
        case .unavailable(let other):
            self = .other("\(other)")
        }
    }
}
