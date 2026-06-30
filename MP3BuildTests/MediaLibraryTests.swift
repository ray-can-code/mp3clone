import XCTest
@testable import MP3Build

@MainActor
final class MediaLibraryTests: XCTestCase {
    func testLibraryPersistsItems() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let library = MediaLibrary(rootDirectory: root)
        let item = MediaItem(title: "Test Song", filename: "test-song.mp3", kind: .audio)

        try library.replaceItems([item])

        let reloaded = MediaLibrary(rootDirectory: root)
        XCTAssertEqual(reloaded.items, [item])
    }

    func testUnsupportedExtensionThrows() {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let library = MediaLibrary(rootDirectory: root)
        let source = root.appendingPathComponent("note.txt")

        XCTAssertThrowsError(try library.makeItem(forImportedFile: source))
    }

    func testPhotoItemUsesFilenameMetadataOnly() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let library = MediaLibrary(rootDirectory: root)
        let source = root.appendingPathComponent("cover-photo.webp")

        let item = try library.makeItem(forImportedFile: source)

        XCTAssertEqual(item.kind, .photo)
        XCTAssertEqual(item.title, "cover-photo")
        XCTAssertEqual(item.filename, "cover-photo.webp")
        XCTAssertNil(item.duration)
    }

    func testFavoritesAndPlaylistsPersistAcrossReloads() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let library = MediaLibrary(rootDirectory: root)
        let item = MediaItem(
            id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
            title: "Favorite Track",
            filename: "favorite-track.mp3",
            kind: .audio
        )

        try library.replaceItems([item])
        try library.toggleFavorite(item)
        try library.add(item, toPlaylistNamed: "Wheel Mix")

        let reloaded = MediaLibrary(rootDirectory: root)

        XCTAssertTrue(reloaded.isFavorite(item))
        XCTAssertEqual(reloaded.playlists.first(where: { $0.name == "Wheel Mix" })?.itemIDs, [item.id])
        XCTAssertEqual(reloaded.items(in: reloaded.playlists.first(where: { $0.name == "Wheel Mix" }) ?? MediaPlaylist(name: "Missing")), [item])
    }

    func testDeleteRemovesResumeFavoriteAndPlaylistState() throws {
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let library = MediaLibrary(rootDirectory: root)
        let item = MediaItem(
            id: UUID(uuidString: "20000000-0000-0000-0000-000000000001")!,
            title: "Clip",
            filename: "clip.mp4",
            kind: .video
        )

        try library.replaceItems([item])
        try library.setResumePosition(33, for: item)
        try library.toggleFavorite(item)
        try library.add(item, toPlaylistNamed: "Wheel Mix")
        try library.delete(item)

        let reloaded = MediaLibrary(rootDirectory: root)

        XCTAssertFalse(reloaded.isFavorite(item))
        XCTAssertEqual(reloaded.resumePosition(for: item), 0)
        XCTAssertTrue(reloaded.playlists.allSatisfy { !$0.itemIDs.contains(item.id) })
    }
}
