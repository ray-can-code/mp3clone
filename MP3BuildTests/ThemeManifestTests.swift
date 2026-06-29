import XCTest
@testable import MP3Build

final class ThemeManifestTests: XCTestCase {
    func testManifestDecodesThemeAssetsAndColors() throws {
        let json = """
        {
          "id": "minecraft",
          "name": "Minecraft",
          "fontName": "Minecraft",
          "colors": {
            "bodyTop": "#EEF3F8",
            "bodyBottom": "#AEB8C6",
            "bodyEdge": "#7C8795",
            "screenBackground": "#080A0D",
            "screenGloss": "#8BA0B8",
            "primaryText": "#FFFFFF",
            "secondaryText": "#D8DDE5",
            "focus": "#D8D8D8",
            "wheel": "#EDF2F7",
            "wheelShadow": "#000000",
            "wheelGlyph": "#52677A"
          },
          "assets": {
            "wallpaper": "desk_bg001",
            "statusBattery": "battery_004",
            "menuIcons": {
              "music": "Music",
              "videos": "Videos"
            }
          }
        }
        """.data(using: .utf8)!

        let manifest = try JSONDecoder().decode(ThemeManifest.self, from: json)

        XCTAssertEqual(manifest.id, "minecraft")
        XCTAssertEqual(manifest.assets.wallpaper, "desk_bg001")
        XCTAssertEqual(manifest.assets.menuIcons["music"], "Music")
        XCTAssertEqual(manifest.colors.bodyTop, "#EEF3F8")
    }
}
