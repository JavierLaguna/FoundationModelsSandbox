import SwiftUI

// MARK: - Native AI Response Panel (Apple HIG compliant)
struct AIResponseView: View {
    let response: String
    let code: String
    let footer: String
    let isLoading: Bool
    
    @ViewBuilder
    private var responseContent: some View {
        if response.isEmpty {
            emptyState
            
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Response text
                    Text(response)
                        .font(.body)
                        .lineSpacing(4)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Code block with native styling
                    if !code.isEmpty {
                        codeBlock
                    }
                    
                    // Footer text
                    Text(footer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(Spacing.lg)
            }
        }
    }
    
    @ViewBuilder
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            
            Image(systemName: "text.bubble")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)
            
            Text(String(localized: "Enter a prompt to generate an AI response"))
                .font(.title3)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(String(localized: "JavaScript"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    // Copy code
                } label: {
                    Label(String(localized: "Copy"), systemImage: "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.appSecondaryBackground)
            
            Divider()
            
            // Code content
            ScrollView(.horizontal, showsIndicators: false) {
                SyntaxHighlightedCode(code: code)
                    .padding(Spacing.md)
            }
            .background(Color.codeBackground)
        }
        .liquidGlass(cornerRadius: CornerRadius.medium)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                title: String(localized: "AI Response"),
                statusColor: Color.successGreen
            ) {
                Button(action: {}) {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }
            
            Divider()
            
            if isLoading {
                LoadingAppleIntelligence(text: String(localized: "Generating response..."))
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity
                    )
                
            } else {
                responseContent
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}

#Preview {
    AIResponseView(
        response: "To implement a real-time data stream in your application, you should use WebSockets or Server-Sent Events (SSE).",
        code: """
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });
""",
        footer: "This implementation creates a simple WebSocket server that listens on port 8080.",
        isLoading: false
    )
    .frame(width: 450, height: 700)
}
