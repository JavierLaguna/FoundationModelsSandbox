import SwiftUI

struct LoadingAppleIntelligence: View {

    private let text: String?

    init(text: String? = nil) {
        self.text = text
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            AppleIntelligenceAnimation(size: 64)

            if let text {
                Text(text)
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    LoadingAppleIntelligence()

    LoadingAppleIntelligence(text: "Generating with AI...")
}
