import SwiftUI

// MARK: - Native AI Response Panel (Apple HIG compliant)
struct AIResponseView: View {
    let response: String
    let code: String
    let footer: String
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Header
            header
            
            Divider()
            
            // MARK: - Content
            if isLoading {
                loadingView
            } else {
                responseContent
            }
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Header
    private var header: some View {
        HStack {
            Circle()
                .fill(Color.successGreen)
                .frame(width: 8, height: 8)
            
            Text("AI Response")
                .font(.headline)
            
            Spacer()
            
            // Copy button
            Button {
                // Copy to clipboard
            } label: {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.appGroupedBackground)
    }
    
    // MARK: - Loading View
    private var loadingView: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Generating response...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Response Content
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
                    
                    // Code block with native styling
                    if !code.isEmpty {
                        codeBlock
                    }
                    
                    // Footer text
                    Text(footer)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                }
                .padding(Spacing.lg)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: Spacing.md) {
            Spacer()
            
            Image(systemName: "text.bubble")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            
            Text("Enter a prompt to generate an AI response")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Code Block
    private var codeBlock: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("JavaScript")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button {
                    // Copy code
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
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