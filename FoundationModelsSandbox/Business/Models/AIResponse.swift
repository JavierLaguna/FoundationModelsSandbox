import Foundation

/// Represents an AI response with content and performance metrics
struct AIResponse: Sendable, Equatable {
    /// The generated text content from the model
    let content: String

    /// Duration of the response generation in seconds
    let duration: TimeInterval

    /// Number of tokens in the input prompt
    let promptTokenCount: Int

    /// Number of tokens in the model's response
    let responseTokenCount: Int

    /// Total tokens used (prompt + response)
    var totalTokenCount: Int {
        promptTokenCount + responseTokenCount
    }

    /// Maximum context size of the model (if available)
    let contextSize: Int?

    /// Formatted duration string (e.g., "1.23s")
    var formattedDuration: String {
        String(format: "%.2fs", duration)
    }

    /// Formatted token counts string (e.g., "14 → 42 (56 total)")
    var formattedTokenCounts: String {
        let total = totalTokenCount
        if let context = contextSize {
            let percentage = Double(total) / Double(context) * 100
            return "\(promptTokenCount) → \(responseTokenCount) (\(total) total, \(String(format: "%.1f", percentage))% context)"
        }
        return "\(promptTokenCount) → \(responseTokenCount) (\(total) total)"
    }
}