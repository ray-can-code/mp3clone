import Foundation

struct ThemeManifest: Codable, Equatable {
    var id: String
    var name: String
    var fontName: String?
    var colors: ThemeColors
    var assets: ThemeAssets
    var animation: ThemeAnimation?

    struct ThemeColors: Codable, Equatable {
        var bodyTop: String
        var bodyBottom: String
        var bodyEdge: String
        var screenBackground: String
        var screenGloss: String
        var primaryText: String
        var secondaryText: String
        var focus: String
        var wheel: String
        var wheelShadow: String
        var wheelGlyph: String
    }

    struct ThemeAssets: Codable, Equatable {
        var wallpaper: String?
        var screenOverlay: String?
        var statusBattery: String?
        var menuIcons: [String: String]
    }

    struct ThemeAnimation: Codable, Equatable {
        var menuTransitionMilliseconds: Int
        var iconFloatAmplitude: Double
    }

    static let bundledMinecraft = ThemeManifest(
        id: "minecraft",
        name: "Minecraft",
        fontName: "Minecraft",
        colors: ThemeColors(
            bodyTop: "#EEF3F8",
            bodyBottom: "#AEB8C6",
            bodyEdge: "#7C8795",
            screenBackground: "#080A0D",
            screenGloss: "#8BA0B8",
            primaryText: "#FFFFFF",
            secondaryText: "#D8DDE5",
            focus: "#D8D8D8",
            wheel: "#EDF2F7",
            wheelShadow: "#000000",
            wheelGlyph: "#52677A"
        ),
        assets: ThemeAssets(
            wallpaper: "desk_bg001",
            screenOverlay: nil,
            statusBattery: "battery_004",
            menuIcons: [
                "nowPlaying": "Now Playing",
                "music": "Music",
                "videos": "Videos",
                "audiobooks": "Audiobooks",
                "photos": "Photos",
                "fmRadio": "FM Radio",
                "bluetooth": "Bluetooth",
                "settings": "Settings"
            ]
        ),
        animation: ThemeAnimation(
            menuTransitionMilliseconds: 180,
            iconFloatAmplitude: 4
        )
    )
}
