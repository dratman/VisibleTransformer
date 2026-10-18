import SwiftUI
import AppKit
import VisibleTransformer

// A plain command-line-built executable has no app bundle, so macOS may not
// treat it as a normal foreground app. This delegate forces that on launch.
class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

@main
struct EmbeddingRowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        WindowGroup("Embedding Row") {
            EmbeddingRowView(text: "the cat sa")
                .padding(20)
        }
    }
}

/// Blue for negative values, near-white at zero, red for positive values.
/// `value` is expected to be in -1...1.
func color(forValue value: Float) -> Color {
    let v = Double(max(-1, min(1, value)))
    let a = abs(v)
    // Blend from white toward pure red (positive) or pure blue (negative).
    let other = 1 - 0.85 * a
    return v >= 0 ? Color(red: 1, green: other, blue: other)
                  : Color(red: other, green: other, blue: 1)
}

struct EmbeddingRowView: View {
    let text: String
    private let table = EmbeddingTable()

    private let columnWidth: CGFloat = 60
    private let lineHeight: CGFloat = 80
    private let separatorWidth: CGFloat = 10
    // Covers the colored lines and the character, plus about one more
    // character height (44 points) above the colored lines.
    private let separatorHeight: CGFloat = 80 + 50 + 44

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(Array(text.enumerated()), id: \.offset) { _, character in
                // A thick gray separator before each character's column.
                Rectangle()
                    .fill(Color(white: 0.7))
                    .frame(width: separatorWidth, height: separatorHeight)
                VStack(spacing: 6) {
                    // One thin vertical line per embedding component.
                    HStack(spacing: 0) {
                        ForEach(Array(table.vector(for: character).enumerated()),
                                id: \.offset) { _, value in
                            Rectangle()
                                .fill(color(forValue: value))
                                .frame(width: columnWidth / CGFloat(table.dimension),
                                       height: lineHeight)
                        }
                    }
                    Text(String(character))
                        .font(.system(size: 36, design: .monospaced))
                        .frame(width: columnWidth)
                }
            }
            // Closing separator after the last column.
            Rectangle()
                .fill(Color(white: 0.7))
                .frame(width: separatorWidth, height: separatorHeight)
        }
    }
}
