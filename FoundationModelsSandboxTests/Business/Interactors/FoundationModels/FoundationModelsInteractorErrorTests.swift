import Testing
import Foundation
@testable import FoundationModelsSandbox

struct FoundationModelsInteractorErrorTests {

    @Test
    func noActiveConversation_errorDescription_isLocalized() {
        let error = FoundationModelsInteractorError.noActiveConversation
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test
    func contextOverflow_errorDescription_isLocalized() {
        let error = FoundationModelsInteractorError.contextOverflow
        #expect(error.errorDescription != nil)
        #expect(error.errorDescription?.isEmpty == false)
    }

    @Test
    func noActiveConversation_equalsItself() {
        let error = FoundationModelsInteractorError.noActiveConversation
        #expect(error == .noActiveConversation)
    }

    @Test
    func contextOverflow_equalsItself() {
        let error = FoundationModelsInteractorError.contextOverflow
        #expect(error == .contextOverflow)
    }

    @Test
    func noActiveConversation_notEqualToContextOverflow() {
        #expect(
            FoundationModelsInteractorError.noActiveConversation
                != FoundationModelsInteractorError.contextOverflow
        )
    }

    @Test
    func errorDescriptions_areUnique() {
        let noActive = FoundationModelsInteractorError.noActiveConversation.errorDescription
        let overflow = FoundationModelsInteractorError.contextOverflow.errorDescription
        #expect(noActive != overflow)
    }
}
