import Foundation
import FoundationModels
import Mockable

/// Strategy interface for handling context window overflow.
///
/// Each strategy receives the current transcript and produces a new (truncated)
/// transcript. The interactor is responsible for creating a new session from the
/// returned transcript.
@Mockable
protocol ContextTruncationStrategyHandler: Sendable {
    /// Produces a new transcript with reduced context.
    /// - Parameters:
    ///   - transcript: The current session transcript.
    ///   - model: The active model (needed by strategies that create temporary sessions).
    ///   - sessionProvider: Provider to create temporary sessions if needed.
    /// - Returns: A new transcript that fits within the context window.
    func truncateTranscript(
        _ transcript: Transcript,
        model: SystemLanguageModel,
        sessionProvider: SessionProvider
    ) async throws -> Transcript
}
