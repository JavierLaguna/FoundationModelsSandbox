import Foundation
import FoundationModels

/// Truncation strategy that removes the oldest half of prompt/response exchanges,
/// keeping the instructions entry and the most recent exchanges.
struct DropOldestStrategy: ContextTruncationStrategyHandler {

    func truncateTranscript(
        _ transcript: Transcript,
        model: SystemLanguageModel,
        sessionProvider: SessionProvider
    ) async throws -> Transcript {
        let entries = Array(transcript)

        // Always keep instructions entry (usually the first one)
        let instructionsEntries = entries.filter { entry in
            if case .instructions = entry { return true }
            return false
        }

        // Drop oldest prompt+response pairs, keep the most recent ones
        let nonInstructionEntries = entries.filter { entry in
            if case .instructions = entry { return false }
            return true
        }

        // Drop half of the non-instruction entries (oldest first)
        let entriesToKeep = nonInstructionEntries.suffix(nonInstructionEntries.count / 2)
        let trimmedEntries = instructionsEntries + entriesToKeep

        return Transcript(entries: trimmedEntries)
    }
}
