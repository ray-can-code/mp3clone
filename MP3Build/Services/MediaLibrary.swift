import AVFoundation
import Combine
import Foundation

@MainActor
final class MediaLibrary: ObservableObject {
    enum LibraryError: Error, Equatable {
        case unsupportedFile
        case unreadableFile
    }

    @Published private(set) var items: [MediaItem] = []
    @Published private(set) var resumePositions: [UUID: TimeInterval] = [:]

    private let rootDirectory: URL
    private let indexURL: URL
    private let resumeURL: URL
    private let fileManager: FileManager

    init(
        rootDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0],
        fileManager: FileManager = .default
    ) {
        self.rootDirectory = rootDirectory
        self.indexURL = rootDirectory.appendingPathComponent("library.json")
        self.resumeURL = rootDirectory.appendingPathComponent("resume-positions.json")
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

    func items(sortedBy sortMode: MediaSortMode) -> [MediaItem] {
        switch sortMode {
        case .title:
            return items.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .artist:
            return items.sorted {
                ($0.artist ?? $0.title).localizedCaseInsensitiveCompare($1.artist ?? $1.title) == .orderedAscending
            }
        case .album:
            return items.sorted {
                ($0.album ?? $0.title).localizedCaseInsensitiveCompare($1.album ?? $1.title) == .orderedAscending
            }
        case .recentlyAdded:
            return items.sorted { $0.importedAt > $1.importedAt }
        }
    }

    func items(kind: MediaKind, sortedBy sortMode: MediaSortMode) -> [MediaItem] {
        items(sortedBy: sortMode).filter { $0.kind == kind }
    }

    func makeItem(forImportedFile sourceURL: URL) throws -> MediaItem {
        guard let kind = MediaKind.kind(forExtension: sourceURL.pathExtension) else {
            throw LibraryError.unsupportedFile
        }
        let asset = AVURLAsset(url: sourceURL)
        let metadata = asset.commonMetadata

        return MediaItem(
            title: metadata.stringValue(for: .commonIdentifierTitle)
                ?? sourceURL.deletingPathExtension().lastPathComponent,
            artist: metadata.stringValue(for: .commonIdentifierArtist),
            album: metadata.stringValue(for: .commonIdentifierAlbumName),
            filename: sourceURL.lastPathComponent,
            kind: kind,
            duration: asset.duration.seconds.finiteOrNil
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
        var item = try makeItem(forImportedFile: sourceURL)
        let destination = rootDirectory.appendingPathComponent(item.filename)

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        do {
            try fileManager.copyItem(at: sourceURL, to: destination)
        } catch {
            throw LibraryError.unreadableFile
        }

        item.artworkFilename = try saveArtworkIfAvailable(from: sourceURL, itemID: item.id)

        items.removeAll { $0.filename == item.filename }
        items.append(item)
        items.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        try save()
    }

    func delete(_ item: MediaItem) throws {
        let destination = fileURL(for: item)
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        items.removeAll { $0.id == item.id }
        resumePositions[item.id] = nil
        try save()
        try saveResumePositions()
    }

    func setResumePosition(_ position: TimeInterval, for item: MediaItem) throws {
        resumePositions[item.id] = max(0, position)
        try saveResumePositions()
    }

    func resumePosition(for item: MediaItem) -> TimeInterval {
        resumePositions[item.id] ?? 0
    }

    func fileURL(for item: MediaItem) -> URL {
        rootDirectory.appendingPathComponent(item.filename)
    }

    private func load() {
        guard let data = try? Data(contentsOf: indexURL),
              let decoded = try? JSONDecoder().decode([MediaItem].self, from: data) else {
            items = []
            resumePositions = loadResumePositions()
            return
        }

        items = decoded
        resumePositions = loadResumePositions()
    }

    private func save() throws {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(items)
        try data.write(to: indexURL, options: [.atomic])
    }

    private func loadResumePositions() -> [UUID: TimeInterval] {
        guard let data = try? Data(contentsOf: resumeURL),
              let decoded = try? JSONDecoder().decode([UUID: TimeInterval].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveResumePositions() throws {
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        let data = try JSONEncoder().encode(resumePositions)
        try data.write(to: resumeURL, options: [.atomic])
    }

    private func saveArtworkIfAvailable(from sourceURL: URL, itemID: UUID) throws -> String? {
        let metadata = AVURLAsset(url: sourceURL).commonMetadata
        guard let artworkData = metadata.dataValue(for: .commonIdentifierArtwork) else {
            return nil
        }
        let filename = "\(itemID.uuidString)-artwork.bin"
        let destination = rootDirectory.appendingPathComponent(filename)
        try artworkData.write(to: destination, options: [.atomic])
        return filename
    }
}

private extension Array where Element == AVMetadataItem {
    func stringValue(for identifier: AVMetadataIdentifier) -> String? {
        AVMetadataItem.metadataItems(from: self, filteredByIdentifier: identifier).first?.stringValue
    }

    func dataValue(for identifier: AVMetadataIdentifier) -> Data? {
        AVMetadataItem.metadataItems(from: self, filteredByIdentifier: identifier).first?.dataValue
    }
}

private extension Double {
    var finiteOrNil: Double? {
        isFinite ? self : nil
    }
}
