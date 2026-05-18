import Foundation
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct ChatMessageTests {

    // MARK: - Initialization

    @Test
    func init_withRoleAndContent_createsMessageWithDefaultValues() {
        let message = ChatMessage(role: "user", content: "Hello")

        #expect(message.role == "user")
        #expect(message.content == "Hello")
    }

    @Test
    func init_withAllParameters_createsMessageWithProvidedValues() {
        let timestamp = Date(timeIntervalSince1970: 1000)
        let message = ChatMessage(role: "assistant", content: "Response", timestamp: timestamp)

        #expect(message.role == "assistant")
        #expect(message.content == "Response")
        #expect(message.timestamp == timestamp)
    }

    // MARK: - Default Values

    @Test
    func init_defaultTimestamp_isCurrentTime() {
        let before = Date()
        let message = ChatMessage(role: "user", content: "Test")
        let after = Date()

        // Timestamp should be between before and after (approximately)
        #expect(message.timestamp >= before)
        #expect(message.timestamp <= after)
    }

}
