import SwiftUI

// MARK: - Main App View
struct MainView: View {
    @State private var selectedSection: String = "Playground"
    @State private var systemPrompt: String = ""
    @State private var userPrompt: String = ""
    @State private var isLoading: Bool = false
    @State private var aiResponse: String = "To implement a real-time data stream in your application, you should be using WebSockets or Server-Sent Events (SSE). Here is a basic example of a server implementation using Node.js and a client-side listener."
    @State private var showCode: Bool = true
    @State private var selectedModel: String = "GPT-4-TURBO"
    @State private var temperature: Double = 0.7

    let sampleCode = """
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    console.log('received: %s', message);
  });

  ws.send('something');
});
"""

    let responseFooter = "This implementation creates a simple WebSocket server that listens on port 8080. When a client connects, it logs incoming messages and sends a confirmation back. Ensure you handle reconnection logic on the client side for a production-ready application."

    var body: some View {
        HStack(spacing: 0) {
            // MARK: Sidebar
            SidebarView(selectedSection: $selectedSection)
                .frame(width: 250)

            Divider()
                .background(Color.nexusBorder)

            // MARK: Center Panel
            PromptPanelView(
                systemPrompt: $systemPrompt,
                userPrompt: $userPrompt,
                selectedModel: $selectedModel,
                isLoading: $isLoading
            )
            .frame(minWidth: 400)

            Divider()
                .background(Color.nexusBorder)

            // MARK: Right Panel - AI Response
            AIResponseView(
                response: aiResponse,
                code: sampleCode,
                footer: responseFooter,
                isLoading: isLoading
            )
            .frame(minWidth: 400)
        }
        .background(Color.nexusBackground)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preview
#Preview {
    MainView()
        .frame(width: 1200, height: 800)
}
