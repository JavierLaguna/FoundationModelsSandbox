import SwiftUI

// MARK: - Apple Intelligence Animation
struct AppleIntelligenceAnimation: View {
    
    let size: CGFloat
    
    var body: some View {
        KeyframeAnimator(initialValue: 0.0, repeating: true) { rotation in
            Image(systemName: "apple.intelligence")
                .font(.system(size: size))
                .rotationEffect(.init(degrees: rotation))

        } keyframes: { _ in
            LinearKeyframe(0, duration: 0)
            LinearKeyframe(360, duration: 5)
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        AppleIntelligenceAnimation(size: 32)
        AppleIntelligenceAnimation(size: 64)
        AppleIntelligenceAnimation(size: 96)
    }
}