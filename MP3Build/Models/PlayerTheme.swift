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
    var screenWallpaperName: String?
    var fontName: String
    var fontResourceName: String?
    var selectedRowImageName: String?
    var selectedRowArrowImageName: String?
    var batteryImageName: String?
    var homeIconNames: [PlayerScreen: String]

    func homeIconName(for screen: PlayerScreen) -> String? {
        homeIconNames[screen]
    }

    func screenFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        guard fontResourceName != nil else {
            return .system(size: size, weight: weight, design: .rounded)
        }

        return .custom(fontName, size: size).weight(weight)
    }

    static let defaultTheme = PlayerTheme.minecraft

    static let minecraft = PlayerTheme(
        name: "Minecraft",
        bodyTop: Color(red: 0.93, green: 0.96, blue: 0.99),
        bodyBottom: Color(red: 0.62, green: 0.68, blue: 0.75),
        bodyEdge: Color(red: 0.42, green: 0.47, blue: 0.54),
        screenBackground: Color(red: 0.03, green: 0.03, blue: 0.04),
        screenGloss: Color.white.opacity(0.26),
        primaryText: .white,
        secondaryText: Color.white.opacity(0.78),
        focus: Color(red: 0.82, green: 0.83, blue: 0.83),
        wheel: Color(red: 0.90, green: 0.94, blue: 0.98),
        wheelShadow: Color.black.opacity(0.23),
        wheelGlyph: Color(red: 0.18, green: 0.25, blue: 0.31),
        screenWallpaperName: "desk_bg001",
        fontName: "Minecraft",
        fontResourceName: "minecraft",
        selectedRowImageName: "1",
        selectedRowArrowImageName: "2",
        batteryImageName: "battery_004",
        homeIconNames: [
            .nowPlaying: "Now Playing",
            .music: "Music",
            .videos: "Videos",
            .audiobooks: "Audiobooks",
            .photos: "Photos",
            .fmRadio: "FM Radio",
            .bluetooth: "Bluetooth",
            .settings: "Settings"
        ]
    )

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
        wheelGlyph: Color.black.opacity(0.58),
        screenWallpaperName: nil,
        fontName: "System",
        fontResourceName: nil,
        selectedRowImageName: nil,
        selectedRowArrowImageName: nil,
        batteryImageName: nil,
        homeIconNames: [
            .nowPlaying: "Now Playing",
            .music: "Music",
            .videos: "Videos",
            .settings: "Settings"
        ]
    )
}

private struct PlayerThemeKey: EnvironmentKey {
    static let defaultValue = PlayerTheme.defaultTheme
}

extension EnvironmentValues {
    var playerTheme: PlayerTheme {
        get { self[PlayerThemeKey.self] }
        set { self[PlayerThemeKey.self] = newValue }
    }
}
