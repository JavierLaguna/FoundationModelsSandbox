import Foundation

/// Represents a conversation session containing all prompt-response exchanges
struct ConversationSession: Identifiable, Sendable {
    let id: UUID
    let createdAt: Date
    var modelName: String
    var instructions: String
    var messages: [MessageEntry]

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        modelName: String = "",
        instructions: String = ""
    ) {
        self.id = id
        self.createdAt = createdAt
        self.modelName = modelName
        self.instructions = instructions
        self.messages = []
    }

    /// Adds a new message entry to the session
    mutating func addMessage(prompt: String, outcome: SessionOutcome) {
        let entry = MessageEntry(prompt: prompt, outcome: outcome)
        messages.append(entry)
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