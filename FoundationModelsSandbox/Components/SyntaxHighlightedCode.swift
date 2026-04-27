import SwiftUI

// MARK: - Syntax Highlighted Code (Native Style)
struct SyntaxHighlightedCode: View {
    let code: String
    
    var body: some View {
        Text(attributedCode)
            .font(.system(.body, design: .monospaced))
            .lineSpacing(4)
    }
    
    private var attributedCode: AttributedString {
        var result = AttributedString(code)
        
        // Color keywords
        let keywords = ["const", "let", "var", "function", "async", "await", "return", "new", "require", "import", "export", "class", "extends", "if", "else", "for", "while"]
        
        for keyword in keywords {
            var searchStart = result.startIndex
            while searchStart < result.endIndex {
                guard let range = result[searchStart...].range(of: keyword) else { break }
                result[range].foregroundColor = Color.codeKeyword
                searchStart = range.upperBound
            }
        }
        
        // Color strings (simple approach)
        let stringPattern = "\""
        var stringStart: String.Index? = nil
        
        for (index, char) in code.enumerated() {
            if char == "\"" {
                let idx = code.index(code.startIndex, offsetBy: index)
                if stringStart == nil {
                    stringStart = idx
                } else {
                    if let start = stringStart {
                        let startOffset = code.distance(from: code.startIndex, to: start)
                        let endOffset = code.distance(from: code.startIndex, to: idx) + 1
                        
                        let attrStart = result.index(result.startIndex, offsetByCharacters: startOffset)
                        let attrEnd = result.index(result.startIndex, offsetByCharacters: endOffset)
                        
                        if attrStart < attrEnd && attrEnd <= result.endIndex {
                            result[attrStart..<attrEnd].foregroundColor = Color.codeString
                        }
                    }
                    stringStart = nil
                }
            }
        }
        
        return result
    }
}

#Preview {
    SyntaxHighlightedCode(code: """
const WebSocket = require('ws');
const wss = new WebSocket.Server({ port: 8080 });

async function connect() {
  return await wss.connect();
}
""")
    .padding()
    .background(Color.codeBackground)
}