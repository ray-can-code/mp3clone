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
}
