import SwiftUI

// MARK: - Native Prompt Panel (Apple HIG compliant)
struct PromptPanelView: View {
    @Binding var systemPrompt: String
    @Binding var userPrompt: String
    @Binding var selectedModel: String
    @Binding var isLoading: Bool
    
    private let models = ["GPT-4-TURBO", "GPT-4", "GPT-3.5-TURBO", "Claude 3 Opus"]
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Toolbar
            toolbar
            
            Divider()
            
            // MARK: - Content
            ScrollView {
                VStack(spacing: Spacing.lg) {
                    systemPromptSection
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
            
            Menu {
                Button("Export as JSON") {}
                Button("Export as Markdown") {}
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            
            Button {
                // Deploy action
            } label: {
                Label("Deploy", systemImage: "arrow.up.forward.circle")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, Spacing.lg)
        .padding(.vertical, Spacing.sm)
        .background(Color.appGroupedBackground)
    }
    
    // MARK: - System Prompt Section
    private var systemPromptSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Label("System Prompt", systemImage: "cpu")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            
            TextEditor(text: $systemPrompt)
                .font(.body)
                .scrollContentBackground(.hidden)
                .frame(minHeight: 120)
                .liquidGlass(cornerRadius: CornerRadius.medium)
            
            Text("Defines the AI's personality and constraints")
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
            // Context attachment
            Button {
                // Add context
            } label: {
                Label("Add Context", systemImage: "paperclip")
            }
            .buttonStyle(.borderless)
            
            Spacer()
            
            // Model Picker
            Picker("Model", selection: $selectedModel) {
                ForEach(models, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 160)
            
            // Send Button
            Button {
                withAnimation {
                    isLoading = true
                }
                // Simulate loading
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                }
            } label: {
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

#Preview {
    PromptPanelView(
        systemPrompt: .constant("You are a helpful assistant."),
        userPrompt: .constant("Hello, world!"),
        selectedModel: .constant("GPT-4-TURBO"),
        isLoading: .constant(false)
    )
    .frame(width: 450, height: 700)
}