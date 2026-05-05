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

    init(reason: SystemLanguageModel.Availability) {
        switch reason {
        case .available:
            self.text = "Foundation Models are available."
        case .unavailable(let reason):
            self.text = String(describing: reason)
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "apple.intelligence.badge.xmark")
                .font(.largeTitle)

            Text(text)
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ErrorAppleIntelligenceView(text: "text error")
}