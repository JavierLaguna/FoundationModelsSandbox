import Foundation

/// Represents a conversation session containing all prompt-response exchanges
struct ConversationSession: Identifiable, Sendable {
    let id: UUID
    let createdAt: Date
    var modelName: String
    var instructions: String
    var messages: [MessageEntry]
    /// The truncation strategy used when context window is exceeded.
    var truncationStrategy: ContextTruncationStrategy = .dropOldest
    /// JSON-encoded `Transcript` data for session restoration.
    var transcriptData: Data?
    /// Whether the session is marked as a favorite.
    var isFavorite: Bool = false

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        modelName: String = "",
        instructions: String = "",
        truncationStrategy: ContextTruncationStrategy = .dropOldest
    ) {
        self.id = id
        self.createdAt = createdAt
        self.modelName = modelName
        self.instructions = instructions
        self.truncationStrategy = truncationStrategy
        self.messages = []
    }

    /// Adds a new message entry to the session and returns its ID
    @discardableResult
    mutating func addMessage(prompt: String, outcome: SessionOutcome) -> UUID {
        let entry = MessageEntry(prompt: prompt, outcome: outcome)
        messages.append(entry)
        return entry.id
    }

    /// Updates the outcome of an existing message by its ID
    mutating func updateMessage(id: UUID, outcome: SessionOutcome) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].outcome = outcome
        }
    }

    /// Returns the total number of exchanges in this session
    var messageCount: Int {
        messages.count
    }

    /// Returns the most recent outcome, if any
    var latestResponse: SessionOutcome? {
        messages.last?.outcome
    }
}