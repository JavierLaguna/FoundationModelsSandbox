import Foundation
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct SessionOutcomeTests {

    // MARK: - content

    @Test
    func content_withSuccess_returnsResponseContent() {
        let response = AIResponse(
            content: "Hello, world!",
            duration: 1.0,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )
        let outcome = SessionOutcome.success(response)

        #expect(outcome.content == "Hello, world!")
    }

    @Test
    func content_withFailure_returnsEmptyString() {
        let outcome = SessionOutcome.failure("Network error")

        #expect(outcome.content == "")
    }

    @Test
    func content_withNoResponse_returnsEmptyString() {
        let outcome = SessionOutcome.noResponse

        #expect(outcome.content == "")
    }

    // MARK: - formattedMetrics

    @Test
    func formattedMetrics_withSuccess_returnsFormattedString() {
        let response = AIResponse(
            content: "Test",
            duration: 2.5,
            promptTokenCount: 10,
            responseTokenCount: 20,
            contextSize: 128_000
        )
        let outcome = SessionOutcome.success(response)

        #expect(outcome.formattedMetrics != nil)
        #expect(outcome.formattedMetrics?.contains("2.50s") == true)
    }

    @Test
    func formattedMetrics_withFailure_returnsNil() {
        let outcome = SessionOutcome.failure("Error")

        #expect(outcome.formattedMetrics == nil)
    }

    @Test
    func formattedMetrics_withNoResponse_returnsNil() {
        let outcome = SessionOutcome.noResponse

        #expect(outcome.formattedMetrics == nil)
    }

    // MARK: - hasContent

    @Test
    func hasContent_withSuccessAndNonEmptyContent_returnsTrue() {
        let response = AIResponse(
            content: "Some content",
            duration: 1.0,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )
        let outcome = SessionOutcome.success(response)

        #expect(outcome.hasContent == true)
    }

    @Test
    func hasContent_withSuccessAndEmptyContent_returnsFalse() {
        let response = AIResponse(
            content: "",
            duration: 1.0,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )
        let outcome = SessionOutcome.success(response)

        #expect(outcome.hasContent == false)
    }

    @Test
    func hasContent_withFailure_returnsFalse() {
        let outcome = SessionOutcome.failure("Error")

        #expect(outcome.hasContent == false)
    }

    @Test
    func hasContent_withNoResponse_returnsFalse() {
        let outcome = SessionOutcome.noResponse

        #expect(outcome.hasContent == false)
    }
}