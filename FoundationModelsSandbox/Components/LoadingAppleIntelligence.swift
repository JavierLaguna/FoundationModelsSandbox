import SwiftUI

struct LoadingAppleIntelligence: View {

    private let textKey: LocalizedStringKey?

    init(text: LocalizedStringKey? = nil) {
        self.textKey = text
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            AppleIntelligenceAnimation(size: 64)

            if let textKey {
                Text(textKey)
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
