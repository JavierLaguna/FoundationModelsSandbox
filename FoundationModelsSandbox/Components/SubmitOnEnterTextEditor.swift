import SwiftUI
import AppKit

/// A TextEditor variant that handles Enter to submit and Shift+Enter for new lines
struct SubmitOnEnterTextEditor: View {
    
    @Binding var text: String
    var placeholder: Text
    let onSubmit: () -> Void
    var isEnabled: Bool = true
    var accessibilityIdentifier: String = ""
    
    var body: some View {
        SubmitOnEnterTextEditorRepresentable(
            text: $text,
            onSubmit: onSubmit,
            isEnabled: isEnabled,
            accessibilityIdentifier: accessibilityIdentifier
        )
        .overlay(alignment: .topLeading) {
            if text.isEmpty {
                placeholder
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 4)
                    .allowsHitTesting(false)
            }
        }
        .opacity(isEnabled ? 1 : 0.4)
    }
}

// MARK: - Custom NSTextView that handles Enter/Shift+Enter
final class SubmitTextView: NSTextView {
    
    var onEnterPressed: (() -> Void)?
    private var isShiftPressed = false
    
    override func keyDown(with event: NSEvent) {
        // Check if Shift key is pressed
        isShiftPressed = event.modifierFlags.contains(.shift)
        
        // Check for Enter key (keyCode 36)
        if event.keyCode == 36 {
            if isShiftPressed {
                // Shift+Enter: insert newline normally
                super.keyDown(with: event)
            } else {
                // Plain Enter: submit
                onEnterPressed?()
            }
        } else {
            super.keyDown(with: event)
        }
    }
    
    override var acceptsFirstResponder: Bool { true }
}

struct SubmitOnEnterTextEditorRepresentable: NSViewRepresentable {
    
    @Binding var text: String
    let onSubmit: () -> Void
    var isEnabled: Bool = true
    var accessibilityIdentifier: String = ""
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let textView = context.coordinator.textView
        
        textView.delegate = context.coordinator
        textView.font = NSFont.preferredFont(forTextStyle: .body)
        textView.textContainerInset = NSSize(width: 0, height: 4)
        textView.backgroundColor = .clear
        textView.isEditable = true
        textView.isSelectable = true
        textView.allowsUndo = true
        textView.isRichText = false
        textView.usesFontPanel = false
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        
        // Configure text container
        textView.textContainer?.containerSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.textContainer?.widthTracksTextView = true
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        
        scrollView.documentView = textView
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        // Update the coordinator's parent so textDidChange writes to the current binding,
        // not the one from makeCoordinator() which may reference an old ViewModel
        context.coordinator.parent = self
        
        if let textView = nsView.documentView as? NSTextView {
            if textView.string != text {
                textView.string = text
            }
            textView.isEditable = isEnabled
            textView.isSelectable = isEnabled
        }
        
        if !accessibilityIdentifier.isEmpty {
            nsView.setAccessibilityIdentifier(accessibilityIdentifier)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var parent: SubmitOnEnterTextEditorRepresentable
        let textView: SubmitTextView
        
        init(_ parent: SubmitOnEnterTextEditorRepresentable) {
            self.parent = parent
            self.textView = SubmitTextView()
            super.init()
            
            // Set up the enter key handler
            self.textView.onEnterPressed = { [weak self] in
                DispatchQueue.main.async {
                    self?.parent.onSubmit()
                }
            }
        }
        
        func textDidChange(_ notification: Notification) {
            if let textView = notification.object as? NSTextView {
                parent.text = textView.string
            }
        }
    }
}
