import Foundation

/// Represents the outcome of a conversation message exchange
enum SessionOutcome: Sendable, Equatable {
    case success(AIResponse)
    case failure(String)
    case noResponse

    /// Returns the AIResponse content if successful, otherwise an empty string
    var content: String {
        switch self {
        case .success(let response):
            return response.content
        case .failure, .noResponse:
            return ""
        }
    }

    /// Returns the formatted metrics if available, otherwise nil
    var formattedMetrics: String? {
        switch self {
        case .success(let response):
            return "\(response.formattedDuration) • \(response.formattedTokenCounts)"
        case .failure, .noResponse:
            return nil
        }
    }

    /// Returns true if this outcome has content to display
    var hasContent: Bool {
        switch self {
        case .success(let response):
            return !response.content.isEmpty
        case .failure, .noResponse:
            return false
        }
    }
}