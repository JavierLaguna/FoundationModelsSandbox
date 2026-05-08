import SwiftUI

// MARK: - Toolbar View (Reusable header component)
struct ToolbarView<TrailingContent: View>: View {
    
    let title: String
    var statusColor: Color? = nil
    @ViewBuilder let trailing: TrailingContent
    
    init(
        title: String,
        statusColor: Color? = nil,
        @ViewBuilder trailing: () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.statusColor = statusColor
        self.trailing = trailing()
    }
    
    var body: some View {
        HStack(spacing: Spacing.sm) {
            if let statusColor = statusColor {
                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            trailing
        }
        .frame(height: 44)
        .padding(.horizontal, Spacing.lg)
        .background(Color.appGroupedBackground)
    }
}

#Preview {
    VStack(spacing: 0) {
        ToolbarView(title: "Prompt Editor")
        
        Divider()
        
        ToolbarView(
            title: "AI Response",
            statusColor: .green
        ) {
            Button(action: {}) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
        }
    }
    .frame(width: 600, height: 200)
}