import FoundationModels
import SwiftUI

// MARK: - Playground View
struct PlaygroundView: View {

    @Bindable var viewModel: PlaygroundViewModel

    init(viewModel: PlaygroundViewModel) {
        self._viewModel = Bindable(wrappedValue: viewModel)
    }

    init() {
        self._viewModel = Bindable(wrappedValue: PlaygroundViewModel())
    }
    
    @ViewBuilder
    private var detailView: some View {
        VStack(spacing: 0) {
            if viewModel.isFoundationModelsAvailable {
                AIResponseView(
                    messages: viewModel.session.messages,
                    isLoading: viewModel.isLoading,
                    isCodeCopied: viewModel.isCodeCopied,
                    onCopyCode: {
                        viewModel.copyCodeToClipboard()
                    },
                    onCopyMessage: {
                        message in viewModel.copyMessageToClipboard(message)
                    }
                )
                
            } else {
                FoundationModelsNotAvailableView(
                    availabilityReason: viewModel.availabilityReason
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            // Context usage footer
            if let footer = viewModel.contextUsageFooter {
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
            }
        }
    }
    
    var body: some View {
        HSplitView {
            PromptPanelView(
                instructions: $viewModel.instructions,
                userPrompt: $viewModel.userPrompt,
                selectedModelName: $viewModel.selectedModelName,
                availableModelNames: viewModel.availableModelNames,
                isLoading: viewModel.isLoading,
                isConversationActive: viewModel.isConversationActive,
                onSubmit: {
                    Task {
                        await viewModel.submitPrompt()
                    }
                },
                onModelChanged: { modelName in
                    viewModel.modelSelectionChanged(to: modelName)
                },
                truncationStrategy: $viewModel.truncationStrategy
            )
            .frame(minWidth: 380, maxHeight: .infinity)
            
            detailView
                .frame(minWidth: 380, maxHeight: .infinity)
        }
    }
}

#Preview {
    PlaygroundView()
        .frame(width: 1200, height: 800)
}
