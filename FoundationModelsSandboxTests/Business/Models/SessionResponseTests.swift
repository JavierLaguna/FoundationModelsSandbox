import Testing
import Foundation
@testable import FoundationModelsSandbox

@MainActor
struct SessionResponseTests {

    @Test
    func init_setsAllProperties() {
        let response = SessionResponse(
            content: "Hello world",
            duration: 1.5,
            promptTokenCount: 10,
            responseTokenCount: 20
        )
        #expect(response.content == "Hello world")
        #expect(response.duration == 1.5)
        #expect(response.promptTokenCount == 10)
        #expect(response.responseTokenCount == 20)
    }

    @Test
    func init_withZeroValues() {
        let response = SessionResponse(
            content: "",
            duration: 0,
            promptTokenCount: 0,
            responseTokenCount: 0
        )
        #expect(response.content == "")
        #expect(response.duration == 0)
        #expect(response.promptTokenCount == 0)
        #expect(response.responseTokenCount == 0)
    }

    @Test
    func init_withLargeValues() {
        let response = SessionResponse(
            content: String(repeating: "a", count: 1000),
            duration: 123.456,
            promptTokenCount: 99999,
            responseTokenCount: 88888
        )
        #expect(response.content.count == 1000)
        #expect(response.duration == 123.456)
        #expect(response.promptTokenCount == 99999)
        #expect(response.responseTokenCount == 88888)
    }

    // MARK: - Equatable

    @Test
    func identicalResponses_areEqual() {
        let a = SessionResponse(content: "Hi", duration: 0.5, promptTokenCount: 5, responseTokenCount: 10)
        let b = SessionResponse(content: "Hi", duration: 0.5, promptTokenCount: 5, responseTokenCount: 10)
        #expect(a == b)
    }

    @Test
    func differentContent_areNotEqual() {
        let a = SessionResponse(content: "Hi", duration: 0.5, promptTokenCount: 5, responseTokenCount: 10)
        let b = SessionResponse(content: "Bye", duration: 0.5, promptTokenCount: 5, responseTokenCount: 10)
        #expect(a != b)
    }

    @Test
    func differentDuration_areNotEqual() {
        let a = SessionResponse(content: "Hi", duration: 0.5, promptTokenCount: 5, responseTokenCount: 10)
        let b = SessionResponse(content: "Hi", duration: 1.0, promptTokenCount: 5, responseTokenCount: 10)
        #expect(a != b)
    }

    @Test
    func differentTokenCounts_areNotEqual() {
        let a = SessionResponse(content: "Hi", duration: 0.5, promptTokenCount: 5, responseTokenCount: 10)
        let b = SessionResponse(content: "Hi", duration: 0.5, promptTokenCount: 10, responseTokenCount: 20)
        #expect(a != b)
    }

    // MARK: - Sendable

    @Test
    func sessionResponse_isSendable() {
        let response = SessionResponse(content: "test", duration: 0, promptTokenCount: 0, responseTokenCount: 0)
        let value: any Sendable = response
        #expect(value as? SessionResponse == response)
    }
}
