//
//  CodeBlockTests.swift
//  FoundationModelsSandboxTests
//
//  Created by Javier Laguna on 17/05/2026.
//

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
        #expect(codeBlock.id != nil)
    }

    // MARK: - Properties

    @Test
    func properties_areAccessible() {
        let codeBlock = CodeBlock(language: "python", code: "print('hello')")

        let language = codeBlock.language
        let code = codeBlock.code
        let id = codeBlock.id

        #expect(language == "python")
        #expect(code == "print('hello')")
        #expect(id != nil)
    }

    // MARK: - Identifiable

    @Test
    func conformsToIdentifiable() {
        let codeBlock = CodeBlock(language: "javascript", code: "console.log('test')")

        // CodeBlock should conform to Identifiable
        let id = codeBlock.id
        #expect(id != nil)
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