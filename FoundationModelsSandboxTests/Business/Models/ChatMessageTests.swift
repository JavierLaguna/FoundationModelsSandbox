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
        #expect(message.id != nil)
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

    // MARK: - Properties

    @Test
    func properties_areAccessible() {
        let message = ChatMessage(role: "user", content: "Test content")

        let role = message.role
        let content = message.content
        let id = message.id
        let timestamp = message.timestamp

        #expect(role == "user")
        #expect(content == "Test content")
        #expect(id != nil)
        #expect(timestamp != nil)
    }

    // MARK: - Identifiable

    @Test
    func conformsToIdentifiable() {
        let message = ChatMessage(role: "user", content: "Test")

        // ChatMessage should conform to Identifiable
        let id = message.id
        #expect(id != nil)
    }
}