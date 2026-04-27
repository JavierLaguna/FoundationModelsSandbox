import SwiftUI

struct PromptPanelView: View {
    @Binding var systemPrompt: String
    @Binding var userPrompt: String
    @Binding var selectedModel: String
    @Binding var isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar
            HStack {
                Spacer()
                Button("Export") {}
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color.nexusTextSecondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.nexusCard)
                    .cornerRadius(7)
                    .overlay(RoundedRectangle(cornerRadius: 7).stroke(Color.nexusBorder, lineWidth: 1))
                    .buttonStyle(.plain)

                Button("Deploy") {}
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(Color.nexusAccent)
                    .cornerRadius(7)
                    .buttonStyle(.plain)

                Divider().frame(height: 28).padding(.horizontal, 4)

                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.system(size: 15))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 15))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 15))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.nexusBackground)

            Divider().background(Color.nexusBorder)

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Search
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.nexusTextMuted)
                        Text("Search templates or chats...")
                            .font(.system(size: 13))
                            .foregroundColor(Color.nexusTextMuted)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 9)
                    .background(Color.nexusCard)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.nexusBorder, lineWidth: 1))

                    // System Prompt Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "circle.grid.3x3")
                                .font(.system(size: 11))
                                .foregroundColor(Color.nexusTextSecondary)
                            Text("SYSTEM PROMPT")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(Color.nexusTextSecondary)
                        }

                        TextEditor(text: $systemPrompt)
                            .font(.system(size: 13))
                            .foregroundColor(Color.nexusText)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 120)
                            .padding(12)
                            .background(Color.nexusCard)
                            .cornerRadius(10)
                            .overlay(
                                Group {
                                    if systemPrompt.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Enter system instructions here...")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color.nexusTextMuted)
                                                    .padding(16)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            )
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.nexusBorder, lineWidth: 1))

                        Text("Defines the AI's personality and constraints.")
                            .font(.system(size: 11))
                            .italic()
                            .foregroundColor(Color.nexusTextMuted)
                    }

                    // User Prompt Section
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left")
                                .font(.system(size: 11))
                                .foregroundColor(Color.nexusTextSecondary)
                            Text("USER PROMPT")
                                .font(.system(size: 10, weight: .semibold))
                                .tracking(1.5)
                                .foregroundColor(Color.nexusTextSecondary)
                        }

                        TextEditor(text: $userPrompt)
                            .font(.system(size: 13))
                            .foregroundColor(Color.nexusText)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 200)
                            .padding(12)
                            .background(Color.nexusCard)
                            .cornerRadius(10)
                            .overlay(
                                Group {
                                    if userPrompt.isEmpty {
                                        VStack {
                                            HStack {
                                                Text("Enter your message here...")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(Color.nexusTextMuted)
                                                    .padding(16)
                                                Spacer()
                                            }
                                            Spacer()
                                        }
                                    }
                                }
                            )
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.nexusBorder, lineWidth: 1))
                    }
                }
                .padding(20)
            }

            Divider().background(Color.nexusBorder)

            // Bottom toolbar
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "paperclip")
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)

                Text("Add Context")
                    .font(.system(size: 12))
                    .foregroundColor(Color.nexusTextSecondary)

                Spacer()

                HStack(spacing: 6) {
                    Text("MODEL:")
                        .font(.system(size: 10, weight: .semibold))
                        .tracking(0.5)
                        .foregroundColor(Color.nexusTextSecondary)

                    Menu(selectedModel) {
                        Button("GPT-4-TURBO") { selectedModel = "GPT-4-TURBO" }
                        Button("GPT-4") { selectedModel = "GPT-4" }
                        Button("GPT-3.5-TURBO") { selectedModel = "GPT-3.5-TURBO" }
                        Button("Claude 3 Opus") { selectedModel = "Claude 3 Opus" }
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color.nexusAccentLight)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.nexusAccent.opacity(0.15))
                    .cornerRadius(5)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.nexusAccent.opacity(0.3), lineWidth: 1))
                }

                Button(action: { isLoading = true }) {
                    HStack(spacing: 6) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.7)
                        } else {
                            Text("Send")
                                .font(.system(size: 13, weight: .semibold))
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 9)
                    .background(Color.nexusAccent)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.nexusBackground)
        }
        .background(Color.nexusBackground)
    }
}

#Preview {
    PromptPanelView(
        systemPrompt: .constant(""),
        userPrompt: .constant(""),
        selectedModel: .constant("GPT-4-TURBO"),
        isLoading: .constant(false)
    )
    .frame(width: 450, height: 700)
}