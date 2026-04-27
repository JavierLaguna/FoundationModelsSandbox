import SwiftUI

// MARK: - Native Metric Tag (Apple HIG compliant)
struct MetricTag: View {
    let label: String
    let icon: String?
    
    init(label: String, icon: String? = nil) {
        self.label = label
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(label)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, Spacing.xs)
        .padding(.vertical, Spacing.xxs)
        .background(Color.appSecondaryBackground)
        .clipShape(Capsule())
    }
}

#Preview {
    HStack(spacing: Spacing.sm) {
        MetricTag(label: "2.4s", icon: "speedometer")
        MetricTag(label: "412 tokens")
        MetricTag(label: "Temp: 0.7", icon: "thermometer")
    }
    .padding()
}