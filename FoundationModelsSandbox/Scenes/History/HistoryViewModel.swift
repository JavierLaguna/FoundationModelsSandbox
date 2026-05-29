import Foundation
import FoundationModels

// MARK: - History ViewModel
@Observable
@MainActor
final class HistoryViewModel {

    // MARK: - Dependencies
    private let sessionRepository: any SessionRepository

    // MARK: - State
    private(set) var sessions: [ConversationSession] = []
    private(set) var isLoading: Bool = false
    private(set) var error: String?
    var searchQuery: String = ""

    // MARK: - Filtered Sessions

    var filteredSessions: [ConversationSession] {
        let trimmed = searchQuery.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return sessions }
        return sessions.filter { session in
            session.firstPrompt?.localizedStandardContains(trimmed) == true ||
            session.lastResponsePreview?.localizedStandardContains(trimmed) == true
        }
    }

    var isSearching: Bool {
        !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Initialization
    init(sessionRepository: any SessionRepository = LiveSessionRepository.makeDefault()) {
        self.sessionRepository = sessionRepository
        loadSessions()
    }

    // MARK: - Toggle Favorite

    func toggleFavorite(id: UUID) {
        guard let index = sessions.firstIndex(where: { $0.id == id }) else { return }
        sessions[index].isFavorite.toggle()
        try? sessionRepository.updateSession(sessions[index])
    }

    // MARK: - Actions
    func loadSessions() {
        isLoading = true
        error = nil

        Task { [weak self] in
            guard let self else { return }
            defer { isLoading = false }
            do {
                sessions = try sessionRepository.allSessions()
            } catch {
                self.error = error.localizedDescription
                sessions = []
            }
        }
    }

    func deleteSession(id: UUID) {
        Task { [weak self] in
            guard let self else { return }
            try? sessionRepository.deleteSession(id: id)
            sessions = (try? sessionRepository.allSessions()) ?? []
        }
    }

    func deleteAllSessions() {
        Task { [weak self] in
            guard let self else { return }
            try? sessionRepository.deleteAllSessions()
            sessions = []
        }
    }
}

// MARK: - Session Display Helpers

extension ConversationSession {

    /// Number of AI responses (successful outcomes) in this session.
    var responseCount: Int {
        messages.filter {
            if case .success = $0.outcome { return true }
            return false
        }.count
    }

    /// Last user prompt text, if any.
    var lastPrompt: String? {
        messages.last?.prompt
    }

    /// First user prompt text, if any.
    var firstPrompt: String? {
        messages.first?.prompt
    }

    /// Text content of the last AI response, if any.
    var lastResponseContent: String? {
        guard let last = messages.last,
              case .success(let response) = last.outcome,
              !response.content.isEmpty
        else { return nil }
        return response.content
    }

    /// Whether the session has any AI responses.
    var hasResponses: Bool {
        responseCount > 0
    }

    /// Short one-line summary of the last response.
    var lastResponsePreview: String? {
        guard let content = lastResponseContent else { return nil }
        let cleaned = content.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.count > 500 ? String(cleaned.prefix(500)) + "..." : cleaned
    }
}
