import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    var role: String
    var content: String
    var timestamp: Date = Date()
}

struct CodeBlock: Identifiable {
    let id = UUID()
    var language: String
    var code: String
}