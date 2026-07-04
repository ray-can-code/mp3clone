import XCTest
@testable import MP3Build

@MainActor
final class PlayerNavigationModelTests: XCTestCase {
    func testWheelMovesSelectionAroundHomeMenu() {
        let model = PlayerNavigationModel()

        model.moveSelection(delta: 1)
        XCTAssertEqual(model.selectedHomeIndex, 1)

        model.moveSelection(delta: -1)
        XCTAssertEqual(model.selectedHomeIndex, 0)
    }

    func testSelectPushesHomeDestination() {
        let model = PlayerNavigationModel()

        model.select()

        XCTAssertEqual(model.currentScreen, .nowPlaying)
    }

    func testHomeEntriesIncludeMinecraftThemePlaceholders() {
        let model = PlayerNavigationModel()
        let titles = model.homeEntries.map(\.title)

        XCTAssertEqual(titles, [
            "Now Playing",
            "Music",
            "Videos",
            "Audiobooks",
            "Photos",
            "FM Radio",
            "Bluetooth",
            "Settings"
        ])
    }

    func testDisabledPlaceholderTabsDoNotOpen() {
        let model = PlayerNavigationModel()
        model.selectedHomeIndex = model.homeEntries.firstIndex(where: { $0.title == "Photos" })!

        model.select()

        XCTAssertEqual(model.currentScreen, .home)
    }
}
