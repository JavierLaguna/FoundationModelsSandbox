//
//  AppLanguageInteractorTests.swift
//  FoundationModelsSandboxTests
//
//  Created by Javier Laguna on 17/05/2026.
//

import Foundation
import Testing
@testable import FoundationModelsSandbox

@MainActor
struct AppLanguageInteractorTests {

    // MARK: - Get Current Language

    @Test
    func getCurrentLanguage_withNoStoredValue_returnsSystem() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        let language = interactor.getCurrentLanguage()

        #expect(language == .system)
    }

    @Test
    func getCurrentLanguage_withStoredEnglish_returnsEnglish() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set("english", forKey: UserDefaultsKeys.appLanguagePreference)
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        let language = interactor.getCurrentLanguage()

        #expect(language == .english)
    }

    @Test
    func getCurrentLanguage_withStoredSpanish_returnsSpanish() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set("spanish", forKey: UserDefaultsKeys.appLanguagePreference)
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        let language = interactor.getCurrentLanguage()

        #expect(language == .spanish)
    }

    @Test
    func getCurrentLanguage_withInvalidValue_returnsSystem() {
        let userDefaults = UserDefaults(suiteName: #function)!
        userDefaults.set("invalid", forKey: UserDefaultsKeys.appLanguagePreference)
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        let language = interactor.getCurrentLanguage()

        #expect(language == .system)
    }

    // MARK: - Set Language

    @Test
    func setLanguage_english_storesEnglishInUserDefaults() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        interactor.setLanguage(.english)

        #expect(userDefaults.string(forKey: UserDefaultsKeys.appLanguagePreference) == "english")
    }

    @Test
    func setLanguage_spanish_storesSpanishInUserDefaults() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        interactor.setLanguage(.spanish)

        #expect(userDefaults.string(forKey: UserDefaultsKeys.appLanguagePreference) == "spanish")
    }

    @Test
    func setLanguage_system_doesNotSetAppleLanguages() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        interactor.setLanguage(.system)

        // For .system, localeIdentifier is nil, so AppleLanguages should not be set
        // The key may or may not exist depending on previous state
        let appleLanguages = userDefaults.stringArray(forKey: UserDefaultsKeys.appleLanguages)
        #expect(appleLanguages == nil || appleLanguages?.isEmpty == true)
    }

    @Test
    func setLanguage_english_setsAppleLanguagesToEn() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        interactor.setLanguage(.english)

        #expect(userDefaults.stringArray(forKey: UserDefaultsKeys.appleLanguages) == ["en"])
    }

    @Test
    func setLanguage_spanish_setsAppleLanguagesToEs() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        interactor.setLanguage(.spanish)

        #expect(userDefaults.stringArray(forKey: UserDefaultsKeys.appleLanguages) == ["es"])
    }

    // MARK: - Get Available Languages

    @Test
    func getAvailableLanguages_returnsAllCases() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        let languages = interactor.getAvailableLanguages()

        #expect(languages == [.system, .english, .spanish])
    }

    // MARK: - Round Trip

    @Test
    func setAndGetLanguage_roundTrip_returnsSameLanguage() {
        let userDefaults = UserDefaults(suiteName: #function)!
        let interactor = AppLanguageInteractorDefault(userDefaults: userDefaults)

        interactor.setLanguage(.spanish)
        let retrieved = interactor.getCurrentLanguage()

        #expect(retrieved == .spanish)
    }
}