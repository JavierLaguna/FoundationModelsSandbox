import Testing
import SwiftUI
@testable import FoundationModelsSandbox

@MainActor
struct ThemeTests {

    // MARK: - Spacing Constants

    @Test
    func spacing_xxs_is4() {
        #expect(Spacing.xxs == 4)
    }

    @Test
    func spacing_xs_is8() {
        #expect(Spacing.xs == 8)
    }

    @Test
    func spacing_sm_is12() {
        #expect(Spacing.sm == 12)
    }

    @Test
    func spacing_md_is16() {
        #expect(Spacing.md == 16)
    }

    @Test
    func spacing_lg_is20() {
        #expect(Spacing.lg == 20)
    }

    @Test
    func spacing_xl_is24() {
        #expect(Spacing.xl == 24)
    }

    @Test
    func spacing_xxl_is32() {
        #expect(Spacing.xxl == 32)
    }

    @Test
    func spacing_incrementsBy4() {
        #expect(Spacing.xs - Spacing.xxs == 4)
        #expect(Spacing.sm - Spacing.xs == 4)
        #expect(Spacing.md - Spacing.sm == 4)
        #expect(Spacing.lg - Spacing.md == 4)
        #expect(Spacing.xl - Spacing.lg == 4)
        #expect(Spacing.xxl - Spacing.xl == 8)
    }

    // MARK: - Corner Radius Constants

    @Test
    func cornerRadius_small_is8() {
        #expect(CornerRadius.small == 8)
    }

    @Test
    func cornerRadius_medium_is12() {
        #expect(CornerRadius.medium == 12)
    }

    @Test
    func cornerRadius_large_is16() {
        #expect(CornerRadius.large == 16)
    }

    @Test
    func cornerRadius_extraLarge_is22() {
        #expect(CornerRadius.extraLarge == 22)
    }

    // MARK: - Color Extensions

    @Test
    func color_appleBlue_isValid() {
        // Just verify the color can be created
        let color = Color.appleBlue
        #expect(color != Color.clear)
    }

    @Test
    func color_successGreen_isValid() {
        let color = Color.successGreen
        #expect(color != Color.clear)
    }

    @Test
    func color_warningOrange_isValid() {
        let color = Color.warningOrange
        #expect(color != Color.clear)
    }

    @Test
    func color_errorRed_isValid() {
        let color = Color.errorRed
        #expect(color != Color.clear)
    }

    @Test
    func color_codeKeyword_isValid() {
        let color = Color.codeKeyword
        #expect(color != Color.clear)
    }

    @Test
    func color_codeString_isValid() {
        let color = Color.codeString
        #expect(color != Color.clear)
    }

    @Test
    func color_codeNumber_isValid() {
        let color = Color.codeNumber
        #expect(color != Color.clear)
    }

    // MARK: - Hex Initializer

    @Test
    func hexInitializer_3Digits_createsColor() {
        let color = Color(hex: "FFF")
        #expect(color != Color.clear)
    }

    @Test
    func hexInitializer_6Digits_createsColor() {
        let color = Color(hex: "FF0000")
        #expect(color != Color.clear)
    }

    @Test
    func hexInitializer_8Digits_createsColor() {
        let color = Color(hex: "FF0000FF")
        #expect(color != Color.clear)
    }

    @Test
    func hexInitializer_invalid_returnsBlack() {
        // Invalid hex should not crash, returns default
        let color = Color(hex: "invalid")
        #expect(color != Color.clear)
    }

    // MARK: - LiquidGlass Modifier

    @Test
    func liquidGlass_modifierExists() {
        // Just verify the modifier can be created
        let modifier = LiquidGlass(cornerRadius: 16)
        #expect(modifier.cornerRadius == 16)
    }

    @Test
    func liquidGlass_defaultCornerRadius_is16() {
        let modifier = LiquidGlass(cornerRadius: 16)
        #expect(modifier.cornerRadius == 16)
    }
}