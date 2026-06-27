import XCTest
@testable import MP3Build

final class MediaItemTests: XCTestCase {
    func testMediaKindClassifiesCommonExtensions() {
        XCTAssertEqual(MediaKind.kind(forExtension: "mp3"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "m4a"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "flac"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "mp4"), .video)
        XCTAssertEqual(MediaKind.kind(forExtension: "MOV"), .video)
        XCTAssertNil(MediaKind.kind(forExtension: "txt"))
    }
}
