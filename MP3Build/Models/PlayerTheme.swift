import SwiftUI

struct PlayerTheme {
    var name: String
    var bodyTop: Color
    var bodyBottom: Color
    var bodyEdge: Color
    var screenBackground: Color
    var screenGloss: Color
    var primaryText: Color
    var secondaryText: Color
    var focus: Color
    var wheel: Color
    var wheelShadow: Color
    var wheelGlyph: Color

    static let sunburstClassic = PlayerTheme(
        name: "Sunburst Classic",
        bodyTop: Color(red: 1.00, green: 0.78, blue: 0.30),
        bodyBottom: Color(red: 0.91, green: 0.56, blue: 0.12),
        bodyEdge: Color(red: 0.73, green: 0.38, blue: 0.02),
        screenBackground: Color(red: 0.04, green: 0.02, blue: 0.10),
        screenGloss: Color(red: 0.08, green: 0.24, blue: 0.35),
        primaryText: .white,
        secondaryText: Color.white.opacity(0.70),
        focus: Color(red: 0.00, green: 0.93, blue: 0.95),
        wheel: Color.white.opacity(0.94),
        wheelShadow: Color.black.opacity(0.18),
        wheelGlyph: Color.black.opacity(0.58)
    )
}

private struct PlayerThemeKey: EnvironmentKey {
    static let defaultValue = PlayerTheme.sunburstClassic
}

extension EnvironmentValues {
    var playerTheme: PlayerTheme {
        get { self[PlayerThemeKey.self] }
        set { self[PlayerThemeKey.self] = newValue }
    }
}
