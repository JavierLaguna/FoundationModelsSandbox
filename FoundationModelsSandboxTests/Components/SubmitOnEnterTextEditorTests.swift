import Testing
import SwiftUI
import AppKit
@testable import FoundationModelsSandbox

// MARK: - SubmitOnEnterTextEditor Coordinator Tests

@MainActor
struct SubmitOnEnterTextEditorTests {

    @Test
    func coordinator_writesToCurrentParentBinding() {
        // Two independent text sources simulating different ViewModel instances
        var textFromSource1 = ""
        var textFromSource2 = ""

        let bindingToSource1 = Binding<String>(
            get: { textFromSource1 },
            set: { textFromSource1 = $0 }
        )

        let bindingToSource2 = Binding<String>(
            get: { textFromSource2 },
            set: { textFromSource2 = $0 }
        )

        // Create a representable with binding to source 1 and get its coordinator
        let representableWithSource1 = SubmitOnEnterTextEditorRepresentable(
            text: bindingToSource1,
            onSubmit: {}
        )
        let coordinator = representableWithSource1.makeCoordinator()

        // Simulate user typing — should write to source 1 via parent's binding
        let textView = coordinator.textView
        textView.string = "first input"
        coordinator.textDidChange(
            Notification(
                name: NSText.didChangeNotification,
                object: textView,
                userInfo: nil
            )
        )

        #expect(textFromSource1 == "first input", "First binding should receive the text")
        #expect(textFromSource2 == "", "Second binding should remain unchanged")

        // Simulate ViewModel replacement: coordinator.parent is updated
        // with a new representable struct that has a binding to source 2
        let representableWithSource2 = SubmitOnEnterTextEditorRepresentable(
            text: bindingToSource2,
            onSubmit: {}
        )
        coordinator.parent = representableWithSource2

        // Simulate more typing — should now write to source 2
        textView.string = "second input"
        coordinator.textDidChange(
            Notification(
                name: NSText.didChangeNotification,
                object: textView,
                userInfo: nil
            )
        )

        #expect(textFromSource1 == "first input", "First binding should be unchanged after parent update")
        #expect(textFromSource2 == "second input", "Second binding should receive the new text after parent update")
    }
}
