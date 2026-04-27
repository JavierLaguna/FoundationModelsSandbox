import SwiftUI

// MARK: - Apple Liquid Glass Theme
// Following Apple Human Interface Guidelines with iOS 26+ Liquid Glass design

extension Color {
    // MARK: - Semantic Colors
    
    /// Primary brand color - Apple's system blue
    static let appleBlue = Color(hex: "#007AFF")
    
    /// Background colors using system materials
    static let appBackground = Color(NSColor.windowBackgroundColor)
    static let appGroupedBackground = Color(NSColor.controlBackgroundColor)
    static let appSecondaryBackground = Color(NSColor.textBackgroundColor)
    
    // MARK: - Glass Effect Colors
    
    /// Frosted glass overlay
    static let glassBackground = Color.adaptive(
        Color.white.opacity(0.08),
        Color.white.opacity(0.5)
    )
    
    static let glassBorder = Color.adaptive(
        Color.white.opacity(0.18),
        Color.black.opacity(0.08)
    )
    
    // MARK: - Text Colors
    
    static let primaryText = Color(NSColor.labelColor)
    static let secondaryText = Color(NSColor.secondaryLabelColor)
    static let tertiaryText = Color(NSColor.tertiaryLabelColor)
    
    // MARK: - Accent Colors
    
    static let accentPrimary = Color.appleBlue
    static let successGreen = Color(hex: "#34C759")
    static let warningOrange = Color(hex: "#FF9500")
    static let errorRed = Color(hex: "#FF3B30")
    
    // MARK: - Code Syntax Colors
    
    static let codeBackground = Color.adaptive(
        Color(white: 0.08),
        Color(white: 0.97)
    )
    static let codeKeyword = Color(hex: "#FF79C6")
    static let codeString = Color(hex: "#F1FA8C")
    static let codeNumber = Color(hex: "#BD93F9")
}

// MARK: - Adaptive Color Helper (macOS)
extension Color {
    static func adaptive(_ dark: Color, _ light: Color) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
                ? NSColor(dark)
                : NSColor(light)
        })
    }
}

// MARK: - Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Liquid Glass Modifier
struct LiquidGlass: ViewModifier {
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(Color.glassBorder, lineWidth: 0.5)
            )
    }
}

extension View {
    func liquidGlass(cornerRadius: CGFloat = 16) -> some View {
        modifier(LiquidGlass(cornerRadius: cornerRadius))
    }
}

// MARK: - Spacing Constants (8pt Grid)
enum Spacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}

// MARK: - Corner Radius
enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let extraLarge: CGFloat = 22
}

#Preview {
    VStack(spacing: 20) {
        Text("Liquid Glass")
            .font(.title2.bold())
            .liquidGlass(cornerRadius: 16)
            .frame(width: 200, height: 60)
        
        RoundedRectangle(cornerRadius: 16)
            .fill(.ultraThinMaterial)
            .frame(width: 200, height: 60)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.appBackground)
}