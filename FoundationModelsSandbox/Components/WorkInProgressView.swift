import SwiftUI

struct WorkInProgressView: View {

    private let message: String

    init(message: String = String(localized: "Work in progress")) {
        self.message = message
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "hammer.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            Text(message)
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