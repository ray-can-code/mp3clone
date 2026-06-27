import Combine
import Foundation

@MainActor
final class MediaLibrary: ObservableObject {
    enum LibraryError: Error, Equatable {
        case unsupportedFile
        case unreadableFile
    }

    @Published private(set) var items: [MediaItem] = []

    private let rootDirectory: URL
    private let indexURL: URL
    private let fileManager: FileManager

    init(
        rootDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0],
        fileManager: FileManager = .default
    ) {
        self.rootDirectory = rootDirectory
        self.indexURL = rootDirectory.appendingPathComponent("library.json")
        self.fileManager = fileManager
        load()
    }

    var audioItems: [MediaItem] {
        items.filter { $0.kind == .audio }
    }

    var videoItems: [MediaItem] {
        items.filter { $0.kind == .video }
    }

    func replaceItems(_ newItems: [MediaItem]) throws {
        items = newItems
        try save()
    }

    func makeItem(forImportedFile sourceURL: URL) throws -> MediaItem {
        guard let kind = MediaKind.kind(forExtension: sourceURL.pathExtension) else {
            throw LibraryError.unsupportedFile
        }

        return MediaItem(
            title: sourceURL.deletingPathExtension().lastPathComponent,
            filename: sourceURL.lastPathComponent,
            kind: kind
        )
    }

    func importFile(from sourceURL: URL) throws {
        let accessed = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if accessed {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        let item = try makeItem(forImportedFile: sourceURL)
        let destination = rootDirectory.appendingPathComponent(item.filename)

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        do {
            try fileManager.copyItem(at: sourceURL, to: destination)
        } catch {
            throw LibraryError.unreadableFile
        }

        items.removeAll { $0.filename == item.filename }
        items.append(item)
        items.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        try save()
    }

    func fileURL(for item: MediaItem) -> URL {
        rootDirectory.appendingPathComponent(item.filename)
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL),
              let decoded = try? JSONDecoder().decode([MediaItem].self, from: data) else {
            items = []
            return
        }

        items = decoded
    }

    private func save() throws {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(items)
        try data.write(to: indexURL, options: [.atomic])
    }
}
