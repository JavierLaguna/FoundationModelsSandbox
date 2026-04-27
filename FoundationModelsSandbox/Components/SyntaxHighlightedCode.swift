import SwiftUI

struct SyntaxHighlightedCode: View {
    let code: String

    var body: some View {
        Text(buildAttributedString())
            .font(.system(size: 12, design: .monospaced))
            .lineSpacing(3)
    }

    func buildAttributedString() -> AttributedString {
        var result = AttributedString(code)

        // Color keywords
        let keywords = ["const", "new", "function", "require"]
        for keyword in keywords {
            var searchRange = result.startIndex..<result.endIndex
            while let range = result[searchRange].range(of: keyword) {
                result[range].foregroundColor = Color.nexusCodeKeyword
                searchRange = range.upperBound..<result.endIndex
            }
        }

        return result
    }
}

#Preview {
    SyntaxHighlightedCode(code: """
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });
""")
    .padding()
    .background(Color.nexusCodeBg)
}