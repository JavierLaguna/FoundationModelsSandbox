import Foundation

struct CodeBlock: Identifiable {
    let id = UUID()
    var language: String
    var code: String
}
