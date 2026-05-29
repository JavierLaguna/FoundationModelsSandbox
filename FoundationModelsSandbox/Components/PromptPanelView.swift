import FoundationModels
import SwiftUI

// MARK: - Native Prompt Panel (Apple HIG compliant)
struct PromptPanelView: View {
    @Binding var instructions: String
    @Binding var userPrompt: String
    @Binding var selectedModelName: String
    let availableModelNames: [String]
    let isLoading: Bool
    let isConversationActive: Bool
    let onSubmit: () -> Void
    let onModelChanged: ((String) -> Void)?
    
    @ViewBuilder
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label("Instructions", systemImage: "cpu")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            SubmitOnEnterTextEditor(
                text: $instructions,
                placeholder: Text("Enter instructions..."),
                onSubmit: onSubmit
            )
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding(Spacing.md)
            .liquidGlass(cornerRadius: CornerRadius.medium)
            .disabled(isConversationActive)
            
            Text("Defines the AI assistant behavior and context")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var userPromptSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label("User Prompt", systemImage: "bubble.left")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            SubmitOnEnterTextEditor(
                text: $userPrompt,
                placeholder: Text("Enter your prompt..."),
                onSubmit: onSubmit
            )
            .font(.body)
            .scrollContentBackground(.hidden)
            .padding(Spacing.md)
            .liquidGlass(cornerRadius: CornerRadius.medium)
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    private var bottomBar: some View {
        HStack(spacing: Spacing.md) {
            Spacer()
            
            // Model Picker
            Picker("Model", selection: $selectedModelName) {
                ForEach(availableModelNames, id: \.self) { name in
                    Text(name).tag(name)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
            .disabled(isConversationActive)
            .onChange(of: selectedModelName) { _, newValue in
                onModelChanged?(newValue)
            }
            
            // Send Button
            Button(action: onSubmit) {
                HStack(spacing: Spacing.xxs) {
                    Text("Send")
                    
                    if isLoading {
                        AppleIntelligenceAnimation(size: 14)
                    } else {
                        Image(systemName: "arrow.up.circle.fill")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.md)
        .background(Color.appGroupedBackground)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Toolbar
            ToolbarView(title: "Prompt Editor")
            
            Divider()
            
            // MARK: - Content
            GlassEffectContainer(spacing: Spacing.lg) {
                VStack(spacing: Spacing.lg) {
                    instructionsSection
                    
                    Divider()
                    
                    userPromptSection
                }
                .frame(maxWidth: .infinity)
            }
            .padding(Spacing.lg)
            
            Divider()
            
            // MARK: - Bottom Bar
            bottomBar
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
    }
}
