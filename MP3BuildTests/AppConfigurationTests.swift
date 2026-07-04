import XCTest
@testable import MP3Build

final class AppConfigurationTests: XCTestCase {
    func testAppDeclaresBackgroundAudioMode() {
        let modes = Bundle.main.object(forInfoDictionaryKey: "UIBackgroundModes") as? [String]

        XCTAssertEqual(modes, ["audio"])
    }
}
