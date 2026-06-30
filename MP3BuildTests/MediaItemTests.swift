import XCTest
@testable import MP3Build

final class MediaItemTests: XCTestCase {
    func testMediaKindClassifiesCommonExtensions() {
        XCTAssertEqual(MediaKind.kind(forExtension: "mp3"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "m4a"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "flac"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "mp4"), .video)
        XCTAssertEqual(MediaKind.kind(forExtension: "MOV"), .video)
        XCTAssertEqual(MediaKind.kind(forExtension: "jpg"), .photo)
        XCTAssertEqual(MediaKind.kind(forExtension: "HEIC"), .photo)
        XCTAssertEqual(MediaKind.kind(forExtension: "webp"), .photo)
        XCTAssertNil(MediaKind.kind(forExtension: "txt"))
    }

    func testMediaKindShortLabelsMatchPlayerBadges() {
        XCTAssertEqual(MediaKind.audio.shortLabel, "AUD")
        XCTAssertEqual(MediaKind.video.shortLabel, "MP4")
        XCTAssertEqual(MediaKind.photo.shortLabel, "PIC")
    }
}
