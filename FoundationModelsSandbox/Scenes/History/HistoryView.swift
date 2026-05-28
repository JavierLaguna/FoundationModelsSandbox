import SwiftUI
import FoundationModels

// MARK: - History View
struct HistoryView: View {
    @Bindable var viewModel: HistoryViewModel
    let onSelectSession: ((ConversationSession) -> Void)?

    init(
        viewModel: HistoryViewModel = HistoryViewModel(),
        onSelectSession: ((ConversationSession) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.onSelectSession = onSelectSession
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if !viewModel.isSearching && viewModel.sessions.isEmpty {
                ContentUnavailableView(
                    "No sessions yet",
                    systemImage: "clock.arrow.circlepath",
                    description: Text("Your conversation history will appear here")
                )
            } else if viewModel.isSearching && viewModel.filteredSessions.isEmpty {
                ContentUnavailableView.search(
                    text: viewModel.searchQuery
                )
            } else {
                sessionList
            }
        }
        .navigationTitle("History")
        .searchable(
            text: $viewModel.searchQuery,
            placement: .automatic,
            prompt: Text("Search sessions…")
        )
        .onAppear {
            viewModel.loadSessions()
        }
    }

    // MARK: - Session List

    private var sessionList: some View {
        List {
            ForEach(viewModel.filteredSessions) { session in
                SessionCard(
                    session: session,
                    onSelect: {
                        onSelectSession?(session)
                    }
                )
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    let session = viewModel.filteredSessions[index]
                    viewModel.deleteSession(id: session.id)
                }
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Session Card

private struct SessionCard: View {
    let session: ConversationSession
    let onSelect: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: Spacing.sm) {
                header

                promptPreview

                lastResponsePreview

                statsFooter
            }

            Spacer()

            Button(action: onSelect) {
                Image(systemName: "arrow.right.circle")
                    .font(.title2)
                    .accessibilityHidden(true)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .help("Open session")
        }
        .padding(Spacing.md)
        .glassEffect(in: .rect(cornerRadius: CornerRadius.large))
        .padding(.bottom, Spacing.md)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: Spacing.xs) {
            Image(systemName: "calendar")
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)

            Text(session.createdAt, style: .date)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Text(session.createdAt, style: .time)
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
        }
    }

    // MARK: - Prompt Preview

    @ViewBuilder
    private var promptPreview: some View {
        if let prompt = session.firstPrompt {
            Text(prompt)
                .font(.body)
                .lineLimit(2)
                .foregroundStyle(.primary)
        } else {
            Text("Empty session")
                .font(.body)
                .foregroundStyle(.tertiary)
                .italic()
        }
    }

    // MARK: - Last Response Preview

    @ViewBuilder
    private var lastResponsePreview: some View {
        if let preview = session.lastResponsePreview {
            Text(preview)
                .font(.system(size: 14))
                .foregroundStyle(.tertiary)
                .lineLimit(5)
        }
    }

    // MARK: - Stats Footer

    private var statsFooter: some View {
        HStack(spacing: Spacing.md) {
            if !session.modelName.isEmpty {
                HStack(spacing: Spacing.xxs) {
                    Image(systemName: "apple.intelligence")
                        .font(.system(size: 16))
                    
                    Text(session.modelName)
                        .font(.system(size: 14))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, Spacing.xxs)
                .background(.quaternary, in: Capsule())
            }
            
            // User prompts count
            statBadge(
                icon: "text.bubble",
                count: session.messageCount
            )

            // AI responses count
            if session.hasResponses {
                statBadge(
                    icon: "checkmark.bubble",
                    count: session.responseCount
                )
            }
        }
    }

    private func statBadge(icon: String, count: Int) -> some View {
        HStack(spacing: Spacing.xxs) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text("\(count)")
                .font(.system(size: 14))
                .fontWeight(.semibold)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, Spacing.sm)
        .padding(.vertical, Spacing.xxs)
        .background(.quaternary, in: Capsule())
    }
}

// MARK: - Preview

#Preview {
    HistoryView()
}
