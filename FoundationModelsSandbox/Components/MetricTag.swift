import SwiftUI

struct MetricTag: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.system(size: 11, weight: .medium))
            .foregroundColor(Color.nexusTextSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Color.nexusCard)
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.nexusBorder, lineWidth: 1))
    }
}

#Preview {
    HStack(spacing: 8) {
        MetricTag(label: "Performance: 2.4s")
        MetricTag(label: "Tokens: 412")
        MetricTag(label: "Temp: 0.7")
    }
    .padding()
}