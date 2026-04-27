import Foundation
import SwiftUI

// MARK: - Main ViewModel
@Observable
final class MainViewModel {
    
    // MARK: - Navigation State
    var selectedSection: String = "Playground"
    
    // MARK: - Prompt State
    var systemPrompt: String = ""
    var userPrompt: String = ""
    var selectedModel: String = "GPT-4-TURBO"
    var isLoading: Bool = false
    
    // MARK: - Available Models
    let availableModels: [String] = [
        "GPT-4-TURBO",
        "GPT-4",
        "GPT-3.5-TURBO",
        "Claude 3 Opus"
    ]
    
    // MARK: - Sample Data (for preview/demo)
    let sampleResponse: String = """
    To implement a real-time data stream in your application, you should use WebSockets or Server-Sent Events (SSE). WebSockets provide full-duplex communication channels over a single TCP connection, making them ideal for real-time applications.
    """
    
    let sampleCode: String = """
    const WebSocket = require('ws');
    
    const wss = new WebSocket.Server({ port: 8080 });
    
    wss.on('connection', (ws) => {
      ws.on('message', (message) => {
        console.log('received: %s', message);
      });
      
      ws.send('Connection established');
    });
    """
    
    let responseFooter: String = "This implementation creates a WebSocket server that listens on port 8080. When a client connects, it logs incoming messages and sends a confirmation back."
    
    // MARK: - Computed Properties
    var canSubmitPrompt: Bool {
        !userPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    // MARK: - Actions
    func submitPrompt() async {
        guard canSubmitPrompt else { return }
        
        isLoading = true
        
        // Simulate API call
        try? await Task.sleep(for: .seconds(2))
        
        isLoading = false
    }
    
    func clearPrompts() {
        systemPrompt = ""
        userPrompt = ""
    }
    
    func selectSection(_ section: String) {
        selectedSection = section
    }
}