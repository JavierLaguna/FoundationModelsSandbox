import FoundationModels
import SwiftUI

struct ErrorAppleIntelligenceView: View {

    private let textKey: LocalizedStringKey

    init(text: LocalizedStringKey) {
        self.textKey = text
    }

    init(error: any Error) {
        self.textKey = LocalizedStringKey(error.localizedDescription)
    }

    init(error: AppleIntelligenceNotAvailableError) {
        self.textKey = LocalizedStringKey(error.errorDescription ?? "")
    }

    init(reason: SystemLanguageModel.Availability) {
        switch reason {
        case .available:
            self.textKey = "Foundation Models are available"
        case .unavailable(let reason):
            self.textKey = LocalizedStringKey(reason.errorDescription)
        }
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "apple.intelligence.badge.xmark")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text(textKey)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorAppleIntelligenceView(text: "text error")
}