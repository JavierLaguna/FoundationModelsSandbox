import FoundationModels
import SwiftUI

// MARK: - Foundation Models Not Available View
struct FoundationModelsNotAvailableView: View {
    
    let availabilityReason: SystemLanguageModel.Availability?
    
    var body: some View {
        if let reason = availabilityReason {
            ErrorAppleIntelligenceView(reason: reason)
        } else {
            ErrorAppleIntelligenceView(reason: .unavailable(.deviceNotEligible))
        }
    }
}

#Preview {
    FoundationModelsNotAvailableView(
        availabilityReason: .unavailable(.deviceNotEligible)
    )
    .frame(width: 380, height: 600)
}