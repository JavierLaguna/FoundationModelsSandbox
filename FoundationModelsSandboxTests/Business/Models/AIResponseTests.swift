//
//  AIResponseTests.swift
//  FoundationModelsSandboxTests
//
//  Created by Javier Laguna on 17/05/2026.
//

import Testing
@testable import FoundationModelsSandbox

@MainActor
struct AIResponseTests {

    @Test
    func totalTokenCount_returnsSumOfPromptAndResponseTokens() {
        let response = AIResponse(
            content: "Hello world",
            duration: 1.5,
            promptTokenCount: 10,
            responseTokenCount: 25,
            contextSize: 128_000
        )

        #expect(response.totalTokenCount == 35)
    }

    @Test
    func totalTokenCount_withZeroTokens_returnsZero() {
        let response = AIResponse(
            content: "",
            duration: 0,
            promptTokenCount: 0,
            responseTokenCount: 0,
            contextSize: nil
        )

        #expect(response.totalTokenCount == 0)
    }

    @Test
    func formattedDuration_formatsDurationWithTwoDecimals() {
        let response = AIResponse(
            content: "Test",
            duration: 1.23456,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )

        #expect(response.formattedDuration == "1.23s")
    }

    @Test
    func formattedDuration_formatsWholeNumberDuration() {
        let response = AIResponse(
            content: "Test",
            duration: 5.0,
            promptTokenCount: 5,
            responseTokenCount: 10,
            contextSize: nil
        )

        #expect(response.formattedDuration == "5.00s")
    }

    @Test
    func formattedTokenCounts_withContextSize_includesPercentage() {
        let response = AIResponse(
            content: "Test",
            duration: 1.0,
            promptTokenCount: 10,
            responseTokenCount: 40,
            contextSize: 100
        )

        #expect(response.formattedTokenCounts == "10 → 40 (50 total, 50.0% context)")
    }

    @Test
    func formattedTokenCounts_withoutContextSize_excludesPercentage() {
        let response = AIResponse(
            content: "Test",
            duration: 1.0,
            promptTokenCount: 10,
            responseTokenCount: 40,
            contextSize: nil
        )

        #expect(response.formattedTokenCounts == "10 → 40 (50 total)")
    }

    @Test
    func formattedTokenCounts_calculatesPercentageCorrectly() {
        let response = AIResponse(
            content: "Test",
            duration: 1.0,
            promptTokenCount: 128,
            responseTokenCount: 128,
            contextSize: 128_000
        )

        #expect(response.formattedTokenCounts.contains("0.2% context"))
    }
}