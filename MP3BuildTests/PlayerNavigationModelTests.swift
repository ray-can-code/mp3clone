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
}
