import SwiftUI

struct SettingsView: View {

    @State private var viewModel = SettingsViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                languageSection
            }
            .padding(Spacing.lg)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.appBackground)
    }

    // MARK: - Language Section
    @ViewBuilder
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            sectionHeader

            VStack(spacing: Spacing.xs) {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    languageRow(language)
                }
            }
        }
        .liquidGlass(cornerRadius: CornerRadius.large)
    }

    @ViewBuilder
    private var sectionHeader: some View {
        Label("Language", systemImage: "globe")
            .font(.headline)
            .foregroundStyle(Color.primaryText)
    }

    @ViewBuilder
    private func languageRow(_ language: AppLanguage) -> some View {
        Button {
            viewModel.selectedLanguage = language
        } label: {
            HStack {
                Text(language.displayName)
                    .foregroundStyle(Color.primaryText)

                Spacer()

                if viewModel.selectedLanguage == language {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentPrimary)
                        .fontWeight(.semibold)
                }
            }
            .padding(.vertical, Spacing.xs)
            .padding(.horizontal, Spacing.sm)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}