import SwiftUI

// MARK: - Native AI Response Panel (Apple HIG compliant)
struct AIResponseView: View {
    let messages: [MessageEntry]
    let isLoading: Bool
    let isCopied: Bool
    let isCodeCopied: Bool
    let onCopy: () -> Void
    let onCopyCode: () -> Void

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

            if messages.isEmpty && !isLoading {
                emptyState
            } else {
                conversationView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }

    @ViewBuilder
    private var conversationView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .trailing, spacing: Spacing.md) {
                    ForEach(messages) { message in
                        MessageBubble(message: message, isCodeCopied: isCodeCopied, onCopyCode: onCopyCode)
                            .id(message.id)
                    }

                    if isLoading {
                        HStack {
                            LoadingAppleIntelligence(text: "Generating response...")
                            Spacer()
                        }
                    }
                }
                .padding(Spacing.lg)
                .frame(maxWidth: .infinity)
            }
            .onChange(of: messages) { _, _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let lastMessage = messages.last {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
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
}

// MARK: - Message Bubble
private struct MessageBubble: View {
    let message: MessageEntry
    let isCodeCopied: Bool
    let onCopyCode: () -> Void

    var body: some View {
        VStack(alignment: .trailing, spacing: Spacing.sm) {
            // Prompt bubble (right-aligned)
            promptBubble

            // Response bubble (left-aligned)
            responseBubble
        }
    }

    @ViewBuilder
    private var promptBubble: some View {
        Text(message.prompt)
            .font(.body)
            .foregroundStyle(Color.primaryText)
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .padding(.leading, Spacing.xl)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
            .background(
                RoundedRectangle(cornerRadius: CornerRadius.medium)
                    .fill(Color.appleBlue.opacity(0.1))
            )
    }

    @ViewBuilder
    private var responseBubble: some View {
        switch message.outcome {
        case .success(let response):
            responseSuccessView(response)

        case .failure(let errorMessage):
            errorView(errorMessage)

        case .noResponse:
            noResponseView
        }
    }

    @ViewBuilder
    private func responseSuccessView(_ response: AIResponse) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(response.content)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(Color.primaryText)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !extractCodeBlock(from: response.content).isEmpty {
                codeBlock(extractCodeBlock(from: response.content))
            }

            metricsFooter(response)
        }
        .padding(Spacing.md)
        .padding(.trailing, Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .liquidGlass(cornerRadius: CornerRadius.medium)
    }

    @ViewBuilder
    private func errorView(_ errorMessage: String) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack(spacing: Spacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red)

                Text("Error")
                    .font(.headline)
                    .foregroundStyle(.red)
            }

            Text(errorMessage)
                .font(.body)
                .foregroundStyle(Color.secondaryText)
                .lineSpacing(3)
        }
        .padding(Spacing.md)
        .padding(.trailing, Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.errorRed.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    @ViewBuilder
    private var noResponseView: some View {
        HStack(spacing: Spacing.sm) {
            ProgressView()
                .controlSize(.small)

            Text("Waiting for response...")
                .font(.caption)
                .foregroundStyle(Color.tertiaryText)

            Spacer()
        }
        .padding(Spacing.md)
        .padding(.trailing, Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.appSecondaryBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
    }

    @ViewBuilder
    private func codeBlock(_ code: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("JavaScript")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)

                Spacer()

                Button(action: onCopyCode) {
                    Label(isCodeCopied ? "Copied" : "Copy", systemImage: isCodeCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.appSecondaryBackground)

            Divider()

            ScrollView(.horizontal, showsIndicators: false) {
                SyntaxHighlightedCode(code: code)
                    .padding(Spacing.md)
            }
            .background(Color.codeBackground)
        }
        .clipShape(RoundedRectangle(cornerRadius: CornerRadius.small))
    }

    @ViewBuilder
    private func metricsFooter(_ metrics: AIResponse) -> some View {
        HStack(spacing: Spacing.md) {
            Label(metrics.formattedDuration, systemImage: "clock")
                .font(.caption)
                .foregroundStyle(Color.tertiaryText)

            Divider()
                .frame(height: 12)

            Label(metrics.formattedTokenCounts, systemImage: "text.alignleft")
                .font(.caption)
                .foregroundStyle(Color.tertiaryText)

            Spacer()
        }
    }

    private func extractCodeBlock(from response: String) -> String {
        let pattern = "```(?:\\w+)?\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: response, range: NSRange(response.startIndex..., in: response)),
              let range = Range(match.range(at: 1), in: response) else {
            return ""
        }
        return String(response[range]).trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

#Preview {
    let messages = [
        MessageEntry(prompt: "Hello, can you explain async/await in Swift?", outcome: .success(AIResponse(content: "Async/await is a modern Swift concurrency feature that allows you to write asynchronous code in a sequential, readable manner.", duration: 1.5, promptTokenCount: 10, responseTokenCount: 25, contextSize: nil))),
        MessageEntry(prompt: "Show me an example", outcome: .success(AIResponse(content: "Here's an example:\n```swift\nfunc fetchData() async throws -> Data {\n    let (data, _) = try await URLSession.shared.data(from: url)\n    return data\n}", duration: 2.0, promptTokenCount: 5, responseTokenCount: 40, contextSize: nil))),
        MessageEntry(prompt: "What about error handling?", outcome: .failure("Network request failed"))
    ]

    AIResponseView(
        messages: messages,
        isLoading: false,
        isCopied: false,
        isCodeCopied: false,
        onCopy: {},
        onCopyCode: {}
    )
    .frame(width: 450, height: 700)
}

#Preview("Empty State") {
    AIResponseView(
        messages: [],
        isLoading: false,
        isCopied: false,
        isCodeCopied: false,
        onCopy: {},
        onCopyCode: {}
    )
    .frame(width: 450, height: 700)
}

#Preview("With Loading") {
    AIResponseView(
        messages: [
            MessageEntry(prompt: "Hello", outcome: .success(AIResponse(content: "Hi there!", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10, contextSize: nil))),
            MessageEntry(prompt: "Tell me a joke", outcome: .noResponse)
        ],
        isLoading: true,
        isCopied: false,
        isCodeCopied: false,
        onCopy: {},
        onCopyCode: {}
    )
    .frame(width: 450, height: 700)
}