import FoundationModels
import SwiftUI

// MARK: - Native Prompt Panel (Apple HIG compliant)
struct PromptPanelView: View {
    @Binding var instructions: String
    @Binding var userPrompt: String
    @Binding var selectedModelName: String
    let availableModelNames: [String]
    let isLoading: Bool
    let onSubmit: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Toolbar
            toolbar
            
            Divider()
            
            // MARK: - Content
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    instructionsSection
                    userPromptSection
                }
                .padding(Spacing.lg)
            }
            
            Divider()
            
            // MARK: - Bottom Bar
            bottomBar
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Toolbar
    private var toolbar: some View {
        HStack {
            Text("Prompt Editor")
                .font(.headline)
            
            Spacer()
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.appGroupedBackground)
    }
    
    // MARK: - Instructions Section
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label("Instructions", systemImage: "cpu")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            TextEditor(text: $instructions)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .liquidGlass(cornerRadius: CornerRadius.medium)
            
            Text("Defines the AI assistant behavior and context")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    // MARK: - User Prompt Section
    private var userPromptSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label("User Prompt", systemImage: "bubble.left")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            TextEditor(text: $userPrompt)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 180)
                .liquidGlass(cornerRadius: CornerRadius.medium)
        }
    }
    
    // MARK: - Bottom Bar
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
            
            // Send Button
            Button(action: onSubmit) {
                HStack(spacing: Spacing.xxs) {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    } else {
                        Text("Send")
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
}