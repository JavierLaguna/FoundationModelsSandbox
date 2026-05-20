import SwiftUI

struct LoadingAppleIntelligence: View {

    enum Layout {
        case vertical
        case horizontal
    }

    private let textKey: LocalizedStringKey?
    private let layout: Layout

    init(text: LocalizedStringKey? = nil, layout: Layout = .vertical) {
        self.textKey = text
        self.layout = layout
    }
    
    @ViewBuilder
    private var verticalLayout: some View {
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

    @ViewBuilder
    private var horizontalLayout: some View {
        HStack(spacing: Spacing.sm) {
            AppleIntelligenceAnimation(size: 24)

            if let textKey {
                Text(textKey)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
    }

    var body: some View {
        switch layout {
        case .vertical:
            verticalLayout
        case .horizontal:
            horizontalLayout
        }
    }
}

#Preview("Vertical") {
    LoadingAppleIntelligence(text: "Generating with AI...")
        .frame(width: 200, height: 150)
}

#Preview("Horizontal") {
    LoadingAppleIntelligence(text: "Generating with AI...", layout: .horizontal)
        .frame(width: 200, height: 80)
}
