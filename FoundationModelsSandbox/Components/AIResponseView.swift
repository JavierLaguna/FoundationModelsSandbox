import SwiftUI

// MARK: - Native AI Response Panel (Apple HIG compliant)
struct AIResponseView: View {
    let messages: [MessageEntry]
    let isLoading: Bool
    let isCopied: Bool
    let isCodeCopied: Bool
    let onCopy: () -> Void
    let onCopyCode: () -> Void

    @State private var canScrollToBottom: Bool = false

    /// Threshold in points: button appears when the user is more than this away from the bottom.
    private static let scrollThreshold: CGFloat = 240

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
                VStack(spacing: 0) {
                    LazyVStack(alignment: .trailing, spacing: Spacing.md) {
                        ForEach(messages) { message in
                            MessageBubble(
                                message: message,
                                isCodeCopied: isCodeCopied,
                                onCopyCode: onCopyCode
                            )
                            .id(message.id)
                        }

                        if isLoading {
                            HStack {
                                Spacer()
                            }
                        }
                    }
                    .padding(Spacing.lg)
                    .frame(maxWidth: .infinity)

                    // Bottom sentinel — OUTSIDE the LazyVStack, after its padding,
                    // at the true end of the scrollable content
                    Color.clear
                        .frame(height: 1)
                        .id("scrollBottom")
                }
            }
            .defaultScrollAnchor(.bottom)
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.visibleRect.maxY >= geometry.contentSize.height - Self.scrollThreshold
            } action: { _, isAtBottom in
                canScrollToBottom = !isAtBottom
            }
            .onChange(of: messages) { _, _ in
                // Defer to next run loop so new content has been laid out
                DispatchQueue.main.async {
                    withAnimation {
                        proxy.scrollTo("scrollBottom", anchor: .bottom)
                    }
                }
            }
            .onAppear {
                // Defer to next run loop to ensure layout is complete
                DispatchQueue.main.async {
                    withAnimation {
                        proxy.scrollTo("scrollBottom", anchor: .bottom)
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Scroll-to-bottom floating button
                if canScrollToBottom {
                    Button {
                        withAnimation {
                            proxy.scrollTo("scrollBottom", anchor: .bottom)
                        }
                    } label: {
                        Image(systemName: "arrow.down")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .glassEffect(in: .circle)
                            )
                            .contentShape(.circle)
                    }
                    .buttonStyle(.borderless)
                    .padding(.bottom, Spacing.sm)
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
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
        HStack {
            Spacer()
            Text(message.prompt)
                .font(.body)
                .foregroundStyle(Color.primaryText)
                .padding(.horizontal, Spacing.md)
                .padding(.vertical, Spacing.sm)
                .glassEffect(in: .rect(cornerRadius: CornerRadius.medium))
                .background(
                    RoundedRectangle(cornerRadius: CornerRadius.medium)
                        .fill(Color.appleBlue.opacity(0.1))
                )
        }
        .padding(.leading, Spacing.xl)
    }

    @ViewBuilder
    private var responseBubble: some View {
        switch message.outcome {
        case .success(let response):
            responseSuccessView(response)

        case .failure(let errorMessage):
            errorView(errorMessage)

        case .noResponse:
            LoadingAppleIntelligence(
                text: "Waiting for response...",
                layout: .horizontal
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, Spacing.xs)
        }
    }

    @ViewBuilder
    private func responseSuccessView(_ response: AIResponse) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text(response.content)
                    .font(.body)
                    .lineSpacing(4)
                    .foregroundStyle(Color.primaryText)

                if !extractCodeBlock(from: response.content).isEmpty {
                    codeBlock(extractCodeBlock(from: response.content))
                }

                metricsFooter(response)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(cornerRadius: CornerRadius.medium)
            Spacer()
        }
        .padding(.trailing, Spacing.xl)
    }

    @ViewBuilder
    private func errorView(_ errorMessage: String) -> some View {
        HStack {
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
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.errorRed.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.medium))
            Spacer()
        }
        .padding(.trailing, Spacing.xl)
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
