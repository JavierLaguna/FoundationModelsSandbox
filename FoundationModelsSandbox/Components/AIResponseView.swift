import SwiftUI

// MARK: - Native AI Response Panel (Apple HIG compliant)
struct AIResponseView: View {
    let messages: [MessageEntry]
    let isLoading: Bool
    let onCopyMessage: (MessageEntry) -> Void
    
    @State private var canScrollToBottom: Bool = false
    
    /// Threshold in points: button appears when the user is more than this away from the bottom.
    private static let scrollThreshold: CGFloat = 240
    
    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                title: "AI Response",
                statusColor: Color.successGreen
            )
            
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
                                onCopyMessage: onCopyMessage
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
            .onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.visibleRect.maxY >= geometry.contentSize.height - Self.scrollThreshold
            } action: { _, isAtBottom in
                canScrollToBottom = !isAtBottom
            }
            .onChange(of: messages) { _, _ in
                // Defer to next run loop so new content has been laid out
                Task { @MainActor in
                    withAnimation {
                        proxy.scrollTo("scrollBottom", anchor: .bottom)
                    }
                }
            }
            .onAppear {
                // Defer to next run loop to ensure layout is complete
                Task { @MainActor in
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
                    .accessibilityIdentifier("response-scroll-to-bottom")
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

// MARK: - Content Segment
private enum ContentSegment {
    case text(String)
    case codeBlock(language: String?, code: String)
}

// MARK: - Message Bubble
private struct MessageBubble: View {
    let message: MessageEntry
    let onCopyMessage: (MessageEntry) -> Void
    
    /// Pre-computed content segments (text ↔ code block) in display order.
    private let contentSegments: [ContentSegment]
    
    /// Code blocks subset for fast copy access (parallel index with `contentSegments` code blocks).
    private let codeBlocks: [(language: String?, code: String)]
    
    /// Maps segment index to code block index (-1 for text segments).
    private let codeBlockIndexForSegment: [Int]
    
    @State private var isMessageCopied = false
    @State private var copiedCodeBlockIndex: Int?
    
    init(
        message: MessageEntry,
        onCopyMessage: @escaping (MessageEntry) -> Void
    ) {
        self.message = message
        self.onCopyMessage = onCopyMessage
        // Parse all segments once at init to avoid regex in body
        if case .success(let response) = message.outcome {
            let segments = Self.parseContentSegments(from: response.content)
            self.contentSegments = segments
            self.codeBlocks = segments.compactMap { segment in
                if case .codeBlock(let language, let code) = segment { return (language, code) } else { return nil }
            }
            var idx = -1
            self.codeBlockIndexForSegment = segments.map { segment in
                if case .codeBlock = segment { idx += 1; return idx } else { return -1 }
            }
        } else {
            self.contentSegments = []
            self.codeBlocks = []
            self.codeBlockIndexForSegment = []
        }
    }
    
    var body: some View {
        GlassEffectContainer(spacing: Spacing.sm) {
            VStack(alignment: .trailing, spacing: Spacing.sm) {
                promptBubble
                responseBubble
            }
        }
    }
    
    private func copyMessageContent() {
        onCopyMessage(message)
        
        isMessageCopied = true
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            isMessageCopied = false
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
                ForEach(contentSegments.indices, id: \.self) { index in
                    contentSegmentView(at: index)
                }
                
                metricsFooter(response)
            }
            .padding(Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .liquidGlass(cornerRadius: CornerRadius.medium)
            .overlay(alignment: .topTrailing) {
                Button(action: copyMessageContent) {
                    Image(systemName: isMessageCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption.weight(.semibold))
                }
                .buttonStyle(.borderless)
                .padding(Spacing.sm)
                .accessibilityIdentifier("response-copy-message")
            }
            Spacer()
        }
        .padding(.trailing, Spacing.xl)
    }
    
    @ViewBuilder
    private func contentSegmentView(at index: Int) -> some View {
        switch contentSegments[index] {
        case .text(let text):
            Text(text)
                .font(.body)
                .lineSpacing(4)
                .foregroundStyle(Color.primaryText)
            
        case .codeBlock(let language, let code):
            let cbIndex = codeBlockIndexForSegment[index]
            codeBlock(
                language: language,
                code: code,
                index: cbIndex,
                isCopied: copiedCodeBlockIndex == cbIndex,
                onCopy: { copyCodeBlock(at: cbIndex) }
            )
        }
    }
    
    private func copyCodeBlock(at index: Int) {
        guard index < codeBlocks.count else { return }
        let code = codeBlocks[index].code
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(code, forType: .string)
        
        copiedCodeBlockIndex = index
        
        Task {
            try? await Task.sleep(for: .seconds(2))
            copiedCodeBlockIndex = nil
        }
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
            .compositingGroup()
            .clipShape(.rect(cornerRadius: CornerRadius.medium))
            Spacer()
        }
        .padding(.trailing, Spacing.xl)
    }
    
    @ViewBuilder
    private func codeBlock(language: String?, code: String, index: Int, isCopied: Bool, onCopy: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(language?.capitalized ?? "Code")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                
                Spacer()
                
                Button(action: onCopy) {
                    Label(isCopied ? "Copied" : "Copy", systemImage: isCopied ? "checkmark" : "doc.on.doc")
                        .font(.caption)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("response-copy-code-\(index)")
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(Color.appSecondaryBackground)
            
            Divider()
            
            SyntaxHighlightedCode(code: code)
                .padding(Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.codeBackground)
        }
        .compositingGroup()
        .clipShape(.rect(cornerRadius: CornerRadius.small))
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
    
    private static func parseContentSegments(from response: String) -> [ContentSegment] {
        let pattern = "```(\\w*)\\n([\\s\\S]*?)```"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [.text(response)] }
        
        let nsString = response as NSString
        let nsRange = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: response, range: nsRange)
        
        var segments: [ContentSegment] = []
        var currentLocation = 0
        
        for match in matches {
            // Text before this code block
            if match.range.location > currentLocation {
                let textRange = NSRange(location: currentLocation, length: match.range.location - currentLocation)
                segments.append(.text(nsString.substring(with: textRange)))
            }
            
            // Code block
            let language: String?
            let langRange = match.range(at: 1)
            if langRange.location != NSNotFound, langRange.length > 0 {
                let lang = nsString.substring(with: langRange)
                language = lang.isEmpty ? nil : lang
            } else {
                language = nil
            }
            
            let codeRange = match.range(at: 2)
            let code = nsString.substring(with: codeRange)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            segments.append(.codeBlock(language: language, code: code))
            
            currentLocation = match.range.location + match.range.length
        }
        
        // Text after last code block
        if currentLocation < nsString.length {
            let textRange = NSRange(location: currentLocation, length: nsString.length - currentLocation)
            segments.append(.text(nsString.substring(with: textRange)))
        }
        
        // If no matches, return the whole content as text
        if segments.isEmpty {
            segments.append(.text(response))
        }
        
        return segments
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
        onCopyMessage: { _ in }
    )
    .frame(width: 450, height: 700)
}

#Preview("Empty State") {
    AIResponseView(
        messages: [],
        isLoading: false,
        onCopyMessage: { _ in }
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
        onCopyMessage: { _ in }
    )
    .frame(width: 450, height: 700)
}
