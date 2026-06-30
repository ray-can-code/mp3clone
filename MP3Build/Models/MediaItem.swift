import Foundation

enum MediaKind: String, Codable, Equatable {
    case audio
    case video
    case photo

    static func kind(forExtension fileExtension: String) -> MediaKind? {
        switch fileExtension.lowercased() {
        case "mp3", "m4a", "aac", "wav", "aiff", "aif", "flac":
            return .audio
        case "mp4", "m4v", "mov":
            return .video
        case "jpg", "jpeg", "png", "heic", "webp":
            return .photo
        default:
            return nil
        }
    }

    var shortLabel: String {
        switch self {
        case .audio: return "AUD"
        case .video: return "MP4"
        case .photo: return "PIC"
        }
    }
}

struct MediaPlaylist: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var itemIDs: [UUID]
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        itemIDs: [UUID] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.itemIDs = itemIDs
        self.createdAt = createdAt
    }
}

struct MediaItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var artist: String?
    var album: String?
    var filename: String
    var artworkFilename: String?
    var kind: MediaKind
    var duration: TimeInterval?
    var importedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        artist: String? = nil,
        album: String? = nil,
        filename: String,
        artworkFilename: String? = nil,
        kind: MediaKind,
        duration: TimeInterval? = nil,
        importedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.filename = filename
        self.artworkFilename = artworkFilename
        self.kind = kind
        self.duration = duration
        self.importedAt = importedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case artist
        case album
        case filename
        case artworkFilename
        case kind
        case duration
        case importedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        artist = try container.decodeIfPresent(String.self, forKey: .artist)
        album = try container.decodeIfPresent(String.self, forKey: .album)
        filename = try container.decode(String.self, forKey: .filename)
        artworkFilename = try container.decodeIfPresent(String.self, forKey: .artworkFilename)
        kind = try container.decode(MediaKind.self, forKey: .kind)
        duration = try container.decodeIfPresent(TimeInterval.self, forKey: .duration)
        importedAt = try container.decodeIfPresent(Date.self, forKey: .importedAt) ?? .distantPast
    }
}
