import XCTest
@testable import MP3Build

@MainActor
final class MediaLibrarySortingTests: XCTestCase {
    func testSortedItemsCanUseTitleArtistAlbumOrRecentOrder() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let library = MediaLibrary(rootDirectory: root)
        let older = MediaItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "Beta",
            artist: "Delta",
            album: "Two",
            filename: "beta.mp3",
            kind: .audio,
            importedAt: Date(timeIntervalSince1970: 1)
        )
        let newer = MediaItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            title: "Alpha",
            artist: "Echo",
            album: "One",
            filename: "alpha.mp3",
            kind: .audio,
            importedAt: Date(timeIntervalSince1970: 2)
        )

        try library.replaceItems([older, newer])

        XCTAssertEqual(library.items(sortedBy: .title).map(\.title), ["Alpha", "Beta"])
        XCTAssertEqual(library.items(sortedBy: .artist).map { $0.artist ?? "" }, ["Delta", "Echo"])
        XCTAssertEqual(library.items(sortedBy: .album).map { $0.album ?? "" }, ["One", "Two"])
        XCTAssertEqual(library.items(sortedBy: .recentlyAdded).map(\.title), ["Alpha", "Beta"])
    }

    func testResumePositionPersistsByItemID() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let library = MediaLibrary(rootDirectory: root)
        let item = MediaItem(title: "Clip", filename: "clip.mp4", kind: .video)

        try library.replaceItems([item])
        try library.setResumePosition(42, for: item)

        let reloaded = MediaLibrary(rootDirectory: root)
        XCTAssertEqual(reloaded.resumePosition(for: item), 42, accuracy: 0.1)
    }
}
