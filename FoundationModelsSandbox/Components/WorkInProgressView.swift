import SwiftUI

struct WorkInProgressView: View {

    private let messageKey: LocalizedStringKey

    init(message: LocalizedStringKey = "Work in progress") {
        self.messageKey = message
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text(messageKey)
                .font(.title3)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    WorkInProgressView()
}