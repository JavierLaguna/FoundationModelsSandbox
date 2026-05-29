import Foundation
import FoundationModels

/// Truncation strategy that summarizes the oldest half of prompt/response exchanges
/// using the model itself, keeping the instructions entry and the most recent exchanges.
struct SummarizeStrategy: ContextTruncationStrategyHandler {

    func truncateTranscript(
        _ transcript: Transcript,
        model: SystemLanguageModel,
        sessionProvider: SessionProvider
    ) async throws -> Transcript {
        let entries = Array(transcript)

        // Always keep instructions entry
        let instructionsEntries = entries.filter { entry in
            if case .instructions = entry { return true }
            return false
        }

        // Non-instruction entries (prompts + responses)
        let nonInstructionEntries = entries.filter { entry in
            if case .instructions = entry { return false }
            return true
        }

        guard !nonInstructionEntries.isEmpty else {
            // No conversation to summarize, return only instructions
            return Transcript(entries: instructionsEntries)
        }

        // Split: older half to summarize, newer half to keep
        let half = nonInstructionEntries.count / 2
        let toSummarize = nonInstructionEntries.prefix(half)
        let toKeep = nonInstructionEntries.suffix(nonInstructionEntries.count - half)

        // Format older conversation entries as text for the model
        let conversationText = formatConversationEntries(Array(toSummarize))

        // Create a temporary session to perform summarization.
        // This uses summarization-specific instructions (small prompt) so it won't overflow.
        let summarySession = sessionProvider.makeSession(
            model: model,
            instructions: "Summarize the key points from the following conversation concisely. Capture the main topics and decisions."
        )

        let summaryResponse = try await summarySession.respond(
            to: Prompt(conversationText),
            options: GenerationOptions(sampling: .greedy)
        )

        // Create a response entry to hold the summary
        let summarySegment = Transcript.Segment.text(
            Transcript.TextSegment(content: summaryResponse.content)
        )
        let summaryResponseEntry = Transcript.Entry.response(
            Transcript.Response(
                assetIDs: [],
                segments: [summarySegment]
            )
        )

        // Build the new transcript: instructions + summary + recent exchanges
        let trimmedEntries = instructionsEntries + [summaryResponseEntry] + toKeep
        return Transcript(entries: trimmedEntries)
    }

    /// Formats an array of transcript entries into a plain-text conversation for summarization.
    private func formatConversationEntries(_ entries: [Transcript.Entry]) -> String {
        var result = ""
        for entry in entries {
            switch entry {
            case .prompt(let prompt):
                let text = prompt.segments.compactMap { segment in
                    if case .text(let textSegment) = segment {
                        return textSegment.content
                    }
                    return nil
                }.joined()
                if !text.isEmpty {
                    result += "User: \(text)\n\n"
                }
            case .response(let response):
                let text = response.segments.compactMap { segment in
                    if case .text(let textSegment) = segment {
                        return textSegment.content
                    }
                    return nil
                }.joined()
                if !text.isEmpty {
                    result += "Assistant: \(text)\n\n"
                }
            default:
                break
            }
        }
        return result
    }
}
