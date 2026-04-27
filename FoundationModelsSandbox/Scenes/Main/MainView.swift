import SwiftUI

// MARK: - Main View (Apple HIG compliant with NavigationSplitView)
struct MainView: View {
    @State private var selectedSection: String = "Playground"
    @State private var systemPrompt: String = ""
    @State private var userPrompt: String = ""
    @State private var isLoading: Bool = false
    @State private var selectedModel: String = "GPT-4-TURBO"
    
    private let sampleResponse = "To implement a real-time data stream in your application, you should use WebSockets or Server-Sent Events (SSE). WebSockets provide full-duplex communication channels over a single TCP connection, making them ideal for real-time applications."
    
    private let sampleCode = """
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

wss.on('connection', (ws) => {
  ws.on('message', (message) => {
    console.log('received: %s', message);
  });
  
  ws.send('Connection established');
});
"""
    
    private let responseFooter = "This implementation creates a WebSocket server that listens on port 8080. When a client connects, it logs incoming messages and sends a confirmation back."
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selectedSection: $selectedSection)
        } content: {
            PromptPanelView(
                systemPrompt: $systemPrompt,
                userPrompt: $userPrompt,
                selectedModel: $selectedModel,
                isLoading: $isLoading
            )
            .frame(minWidth: 380)
        } detail: {
            AIResponseView(
                response: sampleResponse,
                code: sampleCode,
                footer: responseFooter,
                isLoading: isLoading
            )
            .frame(minWidth: 380)
        }
        .navigationSplitViewStyle(.balanced)
    }
}

#Preview {
    MainView()
        .frame(width: 1200, height: 800)
}