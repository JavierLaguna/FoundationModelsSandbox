import Foundation

/// Errors that can occur during a conversation session.
enum FoundationModelsInteractorError: Error, LocalizedError, Equatable {
    case noActiveConversation
    case contextOverflow

    var errorDescription: String? {
        switch self {
        case .noActiveConversation:
            String(localized: "No active conversation. Start a new conversation first.")
        case .contextOverflow:
            String(localized: "The conversation context is full. Try clearing some messages.")
        }
    }
}
