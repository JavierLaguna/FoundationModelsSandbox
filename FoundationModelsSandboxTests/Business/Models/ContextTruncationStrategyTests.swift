import Testing
import Foundation
@testable import FoundationModelsSandbox

@MainActor
struct ContextTruncationStrategyTests {

    @Test
    func allCases_containsDropOldestAndSummarize() {
        let cases = ContextTruncationStrategy.allCases
        #expect(cases.contains(.dropOldest))
        #expect(cases.contains(.summarize))
    }

    @Test
    func allCases_count_is2() {
        #expect(ContextTruncationStrategy.allCases.count == 2)
    }

    @Test
    func dropOldest_rawValue_isDropOldest() {
        #expect(ContextTruncationStrategy.dropOldest.rawValue == "dropOldest")
    }

    @Test
    func summarize_rawValue_isSummarize() {
        #expect(ContextTruncationStrategy.summarize.rawValue == "summarize")
    }

    @Test
    func initFromRawValue_dropOldest_returnsDropOldest() {
        let strategy = ContextTruncationStrategy(rawValue: "dropOldest")
        #expect(strategy == .dropOldest)
    }

    @Test
    func initFromRawValue_summarize_returnsSummarize() {
        let strategy = ContextTruncationStrategy(rawValue: "summarize")
        #expect(strategy == .summarize)
    }

    @Test
    func initFromRawValue_invalidValue_returnsNil() {
        let strategy = ContextTruncationStrategy(rawValue: "manual")
        #expect(strategy == nil)
    }

    @Test
    func dropOldest_isSendable() {
        // Compile-time check: Sendable conformance
        let value: any Sendable = ContextTruncationStrategy.dropOldest
        #expect(value as? ContextTruncationStrategy == .dropOldest)
    }

    @Test
    func strategy_roundTripCodable() throws {
        let original = ContextTruncationStrategy.summarize
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ContextTruncationStrategy.self, from: data)
        #expect(decoded == original)
    }

    // MARK: - displayName

    @Test
    func displayName_dropOldest_returnsNonEmptyString() {
        #expect(!ContextTruncationStrategy.dropOldest.displayName.isEmpty)
    }

    @Test
    func displayName_summarize_returnsNonEmptyString() {
        #expect(!ContextTruncationStrategy.summarize.displayName.isEmpty)
    }

    @Test
    func displayName_allCasesAreDistinct() {
        let names = Set(ContextTruncationStrategy.allCases.map(\.displayName))
        #expect(names.count == ContextTruncationStrategy.allCases.count)
    }
}
