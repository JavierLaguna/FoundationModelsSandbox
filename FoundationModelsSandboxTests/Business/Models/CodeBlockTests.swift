import Foundation
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct CodeBlockTests {

    // MARK: - Initialization

    @Test
    func init_withLanguageAndCode_createsCodeBlock() {
        let codeBlock = CodeBlock(language: "swift", code: "let x = 1")

        #expect(codeBlock.language == "swift")
        #expect(codeBlock.code == "let x = 1")
    }

    // MARK: - Edge Cases

    @Test
    func init_withEmptyLanguage_createsCodeBlock() {
        let codeBlock = CodeBlock(language: "", code: "some code")

        #expect(codeBlock.language == "")
        #expect(codeBlock.code == "some code")
    }

    @Test
    func init_withEmptyCode_createsCodeBlock() {
        let codeBlock = CodeBlock(language: "swift", code: "")

        #expect(codeBlock.language == "swift")
        #expect(codeBlock.code == "")
    }

    @Test
    func init_withMultilineCode_preservesNewlines() {
        let multilineCode = "func test() {\n    let x = 1\n}"
        let codeBlock = CodeBlock(language: "swift", code: multilineCode)

        #expect(codeBlock.code == multilineCode)
    }
}
