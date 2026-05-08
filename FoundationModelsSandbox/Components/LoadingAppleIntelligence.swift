import SwiftUI

struct LoadingAppleIntelligence: View {

    private let text: String?

    init(text: String? = nil) {
        self.text = text
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            KeyframeAnimator(initialValue: 0.0, repeating: true) { rotation in
                Image(systemName: "apple.intelligence")
                    .font(.system(size: 64))
                    .rotationEffect(.init(degrees: rotation))

            } keyframes: { _ in
                LinearKeyframe(0, duration: 0)
                LinearKeyframe(360, duration: 5)
            }

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
