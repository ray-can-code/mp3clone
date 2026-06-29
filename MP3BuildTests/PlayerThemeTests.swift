import XCTest
@testable import MP3Build

final class PlayerThemeTests: XCTestCase {
    func testDefaultThemeIsMinecraft() {
        XCTAssertEqual(PlayerTheme.defaultTheme.name, "Minecraft")
        XCTAssertEqual(PlayerTheme.defaultTheme.screenWallpaperName, "desk_bg001")
        XCTAssertEqual(PlayerTheme.defaultTheme.fontResourceName, "minecraft")
    }

    func testMinecraftThemeMapsHomeIcons() {
        let theme = PlayerTheme.minecraft

        XCTAssertEqual(theme.homeIconName(for: .nowPlaying), "Now Playing")
        XCTAssertEqual(theme.homeIconName(for: .music), "Music")
        XCTAssertEqual(theme.homeIconName(for: .videos), "Videos")
        XCTAssertEqual(theme.homeIconName(for: .audiobooks), "Audiobooks")
        XCTAssertEqual(theme.homeIconName(for: .photos), "Photos")
        XCTAssertEqual(theme.homeIconName(for: .fmRadio), "FM Radio")
        XCTAssertEqual(theme.homeIconName(for: .bluetooth), "Bluetooth")
        XCTAssertEqual(theme.homeIconName(for: .settings), "Settings")
    }
}
