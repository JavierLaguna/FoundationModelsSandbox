import Foundation
import FoundationModels
import Mockable

/// Creates `AIModelSession` instances for the interactor.
@Mockable
protocol SessionProvider: Sendable {
    func makeSession(model: SystemLanguageModel, instructions: String) -> AIModelSession
    func makeSession(model: SystemLanguageModel, transcript: Transcript) -> AIModelSession
}

/// Default implementation that creates real `LiveModelSession` instances.
struct LiveSessionProvider: SessionProvider {

    func makeSession(model: SystemLanguageModel, instructions: String) -> AIModelSession {
        LiveModelSession(model: model, instructions: instructions)
    }

    func makeSession(model: SystemLanguageModel, transcript: Transcript) -> AIModelSession {
        LiveModelSession(model: model, transcript: transcript)
    }
}
