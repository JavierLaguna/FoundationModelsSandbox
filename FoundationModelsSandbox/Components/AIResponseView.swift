import SwiftUI

// MARK: - Native AI Response Panel (Apple HIG compliant)
struct AIResponseView: View {
    let response: String
    let code: String
    let metrics: AIResponse?
    let error: String?
    let isLoading: Bool
    let isCopied: Bool
    let onCopy: () -> Void

    @ViewBuilder
    private var responseContent: some View {
        if response.isEmpty && error == nil {
            emptyState

        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Response text
                    if !response.isEmpty {
                        Text(response)
                            .font(.body)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Error message
                    if let error = error {
                        errorView(error)
                    }

                    // Code block with native styling
                    if !code.isEmpty {
                        codeBlock(code)
                    }

                    // Metrics footer
                    if let metrics = metrics {
                        metricsFooter(metrics)
                    }
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

            Text("Enter a prompt to generate an AI response")
                .font(.title3)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func errorView(_ error: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)

                Text("Error")
                    .font(.headline)
                    .foregroundStyle(.red)
            }

            Text(error)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(3)
        }
        .padding(Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }

    @ViewBuilder
    private func codeBlock(_ code: String) -> some View {
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

    @ViewBuilder
    private func metricsFooter(_ metrics: AIResponse) -> some View {
        HStack(spacing: Spacing.md) {
            // Duration
            Label(metrics.formattedDuration, systemImage: "clock")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Divider()
                .frame(height: 12)

            // Token counts
            Label(metrics.formattedTokenCounts, systemImage: "text.alignleft")
                .font(.caption)
                .foregroundStyle(.tertiary)

            Spacer()
        }
        .padding(.top, Spacing.sm)
    }

    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                title: "AI Response",
                statusColor: Color.successGreen
            ) {
                Button(action: onCopy) {
                    Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                }
                .buttonStyle(.borderless)
            }

            Divider()

            if isLoading {
                LoadingAppleIntelligence(text: "Generating response...")
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
        metrics: AIResponse(
            content: "",
            duration: 1.23,
            promptTokenCount: 14,
            responseTokenCount: 42,
            contextSize: 4096
        ),
        error: nil,
        isLoading: false,
        isCopied: false,
        onCopy: {}
    )
    .frame(width: 450, height: 700)
}

#Preview("With Error") {
    AIResponseView(
        response: "",
        code: "",
        metrics: nil,
        error: "Apple Intelligence is not available on this device",
        isLoading: false,
        isCopied: false,
        onCopy: {}
    )
    .frame(width: 450, height: 700)
}

#Preview("Loading") {
    AIResponseView(
        response: "",
        code: "",
        metrics: nil,
        error: nil,
        isLoading: true,
        isCopied: false,
        onCopy: {}
    )
    .frame(width: 450, height: 700)
}