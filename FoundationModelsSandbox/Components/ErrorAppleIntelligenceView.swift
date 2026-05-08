import FoundationModels
import SwiftUI

struct ErrorAppleIntelligenceView: View {

    private let text: String

    init(text: String) {
        self.text = text
    }

    init(error: any Error) {
        self.text = error.localizedDescription
    }
    
    init(error: AppleIntelligenceNotAvailableError) {
        self.text = error.errorDescription ?? ""
    }

    init(reason: SystemLanguageModel.Availability) {
        switch reason {
        case .available:
            self.text = "Foundation Models are available."
        case .unavailable(let reason):
            self.text = reason.errorDescription
        }
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "apple.intelligence.badge.xmark")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorAppleIntelligenceView(text: "text error")
}
