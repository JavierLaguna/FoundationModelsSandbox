import SwiftUI

struct AIResponseView: View {
    let response: String
    let code: String
    let footer: String
    let isLoading: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Response header
            HStack(spacing: 8) {
                Circle()
                    .fill(Color.nexusGreen)
                    .frame(width: 8, height: 8)
                Text("AI Response")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color.nexusText)
                Spacer()
                Button(action: {}) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 14))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 14))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    Image(systemName: "hand.thumbsup")
                        .font(.system(size: 14))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)

                Divider().frame(height: 20)

                Button(action: {}) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 14))
                        .foregroundColor(Color.nexusTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.nexusBackground)
            .overlay(alignment: .trailing) {
                VStack {
                    Spacer()
                    HStack(spacing: 0) {
                        Spacer()
                        VStack(spacing: 12) {
                            Button(action: {}) {
                                Image(systemName: "chart.bar")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.nexusTextSecondary)
                            }
                            .buttonStyle(.plain)
                            Button(action: {}) {
                                Image(systemName: "bookmark")
                                    .font(.system(size: 13))
                                    .foregroundColor(Color.nexusTextSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                        .background(Color.nexusCard)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.nexusBorder, lineWidth: 1))
                        .padding(.trailing, 4)
                    }
                    .padding(.bottom, 60)
                }
            }

            Divider().background(Color.nexusBorder)

            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Generating response...")
                        .foregroundColor(Color.nexusTextSecondary)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(response)
                            .font(.system(size: 13))
                            .foregroundColor(Color.nexusText)
                            .lineSpacing(5)

                        // Code Block
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("JAVASCRIPT")
                                    .font(.system(size: 10, weight: .semibold))
                                    .tracking(1)
                                    .foregroundColor(Color.nexusTextSecondary)
                                Spacer()
                                Button(action: {}) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "doc.on.doc")
                                            .font(.system(size: 11))
                                        Text("Copy")
                                            .font(.system(size: 11))
                                    }
                                    .foregroundColor(Color.nexusTextSecondary)
                                }
                                .buttonStyle(.plain)

                                Button(action: {}) {
                                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color.nexusTextSecondary)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.nexusCard)

                            Divider().background(Color.nexusBorder)

                            ScrollView(.horizontal, showsIndicators: false) {
                                SyntaxHighlightedCode(code: code)
                                    .padding(14)
                            }
                            .background(Color.nexusCodeBg)
                        }
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.nexusBorder, lineWidth: 1))

                        Text(footer)
                            .font(.system(size: 13))
                            .foregroundColor(Color.nexusText)
                            .lineSpacing(5)

                        // Metrics
                        HStack(spacing: 8) {
                            MetricTag(label: "Performance: 2.4s")
                            MetricTag(label: "Tokens: 412")
                            MetricTag(label: "Temp: 0.7")
                        }
                    }
                    .padding(20)
                }

                Divider().background(Color.nexusBorder)

                // Feedback buttons
                HStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Button(action: {}) {
                            Image(systemName: "hand.thumbsup")
                                .font(.system(size: 16))
                                .foregroundColor(Color.nexusTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .padding(10)
                        .background(Color.nexusCard)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.nexusBorder, lineWidth: 1))

                        Button(action: {}) {
                            Image(systemName: "hand.thumbsdown")
                                .font(.system(size: 16))
                                .foregroundColor(Color.nexusTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .padding(10)
                        .background(Color.nexusCard)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.nexusBorder, lineWidth: 1))

                        Button(action: {}) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 16))
                                .foregroundColor(Color.nexusTextSecondary)
                        }
                        .buttonStyle(.plain)
                        .padding(10)
                        .background(Color.nexusCard)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.nexusBorder, lineWidth: 1))
                    }
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(Color.nexusBackground)
            }
        }
        .background(Color.nexusPanel)
    }
}

#Preview {
    AIResponseView(
        response: "To implement a real-time data stream in your application, you should use WebSockets or Server-Sent Events (SSE).",
        code: """
const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });
""",
        footer: "This implementation creates a simple WebSocket server.",
        isLoading: false
    )
    .frame(width: 450, height: 700)
}