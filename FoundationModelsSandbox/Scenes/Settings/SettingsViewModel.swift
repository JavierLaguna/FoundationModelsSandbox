import Foundation
import SwiftUI

/// ViewModel for the Settings scene.
/// Manages language selection which is persisted via @AppStorage.
@Observable
@MainActor
final class SettingsViewModel: Sendable {

    private let interactor: any SettingsInteractor

    var selectedLanguage: AppLanguage {
        didSet {
            interactor.setLanguage(selectedLanguage)
        }
    }

    let availableLanguages: [AppLanguage]

    init(
        interactor: any SettingsInteractor = SettingsInteractorDefault()
    ) {
        self.interactor = interactor
        self.selectedLanguage = interactor.getCurrentLanguage()
        self.availableLanguages = interactor.getAvailableLanguages()
    }
}
