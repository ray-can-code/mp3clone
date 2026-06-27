# Local iOS Media Player Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a SwiftUI iOS app that turns an iPhone 7 into a local-only Innioasis/iPod-inspired music and MP4 player with a virtual click wheel.

**Architecture:** Create an Xcode-ready SwiftUI app skeleton with focused model, playback, import, theme, navigation, and view files. Keep media files local in the app Documents directory, drive all main navigation through a small embedded device screen, and wrap iOS playback APIs behind testable controllers.

**Tech Stack:** Swift 5, SwiftUI, AVFoundation, AVKit, UniformTypeIdentifiers, XCTest, iOS document picker.

---

## File Structure

- `MP3Build.xcodeproj/project.pbxproj`: Xcode project for an iOS app target and unit test target.
- `MP3Build/MP3BuildApp.swift`: App entry point.
- `MP3Build/Models/MediaItem.swift`: Codable media item model and media kind enum.
- `MP3Build/Models/PlayerTheme.swift`: Theme data model and built-in `Sunburst Classic` theme.
- `MP3Build/Models/PlayerScreen.swift`: Screen routing enum.
- `MP3Build/Services/MediaLibrary.swift`: Imports, indexes, persists, and lists local media.
- `MP3Build/Services/PlaybackController.swift`: Wraps AVFoundation/AVKit state for current playback.
- `MP3Build/Services/PlayerNavigationModel.swift`: Owns screen stack and click-wheel-driven selection.
- `MP3Build/Views/RootDeviceView.swift`: Full-screen physical-device shell.
- `MP3Build/Views/DeviceScreenView.swift`: Embedded screen chrome and router.
- `MP3Build/Views/HomeMenuView.swift`: Home menu screen.
- `MP3Build/Views/MediaListView.swift`: Music and video library screens.
- `MP3Build/Views/NowPlayingView.swift`: Current audio/video playback screen.
- `MP3Build/Views/ClickWheelView.swift`: Virtual click wheel.
- `MP3Build/Views/ImportButton.swift`: Document picker bridge.
- `MP3BuildTests/MediaLibraryTests.swift`: Persistence and import classification tests.
- `MP3BuildTests/PlayerNavigationModelTests.swift`: Menu navigation and click-wheel selection tests.
- `README.md`: Build, signing, and sideload notes.

### Task 1: Project Skeleton

**Files:**
- Create: `MP3Build.xcodeproj/project.pbxproj`
- Create: `MP3Build/MP3BuildApp.swift`
- Create: `MP3Build/Views/RootDeviceView.swift`
- Create: `README.md`

- [ ] **Step 1: Create the SwiftUI app entry point**

Create `MP3Build/MP3BuildApp.swift`:

```swift
import SwiftUI

@main
struct MP3BuildApp: App {
    var body: some Scene {
        WindowGroup {
            RootDeviceView()
        }
    }
}
```

- [ ] **Step 2: Create the first root view**

Create `MP3Build/Views/RootDeviceView.swift`:

```swift
import SwiftUI

struct RootDeviceView: View {
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.70, blue: 0.22)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.black.opacity(0.86))
                    .frame(height: 220)

                Circle()
                    .fill(Color.white.opacity(0.92))
                    .frame(width: 260, height: 260)
            }
            .padding(.horizontal, 28)
        }
    }
}

#Preview {
    RootDeviceView()
}
```

- [ ] **Step 3: Create the Xcode project**

Create `MP3Build.xcodeproj/project.pbxproj` with one iOS application target named `MP3Build` and one unit test target named `MP3BuildTests`. Set the deployment target to iOS 15.0 so the project remains plausible for older devices while using modern SwiftUI APIs.

- [ ] **Step 4: Add the README**

Create `README.md`:

```markdown
# MP3 Build

MP3 Build is a local-only SwiftUI media player for iPhone. It uses an Innioasis/iPod-inspired device shell, a small embedded player screen, and a virtual click wheel.

## Build Requirements

- macOS with Xcode
- iOS signing identity or sideloading workflow
- iPhone 7 or compatible simulator/device

## Current Scope

- Local music import
- Local MP4 import
- Music and video library screens
- Playback inside a small device screen
- Virtual click wheel navigation

The app does not emulate Innioasis firmware and does not use proprietary Innioasis assets.
```

- [ ] **Step 5: Commit**

Run:

```bash
git add MP3Build.xcodeproj MP3Build README.md
git commit -m "chore: scaffold ios media player app"
```

Expected: commit succeeds.

### Task 2: Core Models

**Files:**
- Create: `MP3Build/Models/MediaItem.swift`
- Create: `MP3Build/Models/PlayerTheme.swift`
- Create: `MP3Build/Models/PlayerScreen.swift`
- Create: `MP3BuildTests/MediaItemTests.swift`

- [ ] **Step 1: Write media model tests**

Create `MP3BuildTests/MediaItemTests.swift`:

```swift
import XCTest
@testable import MP3Build

final class MediaItemTests: XCTestCase {
    func testMediaKindClassifiesCommonExtensions() {
        XCTAssertEqual(MediaKind.kind(forExtension: "mp3"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "m4a"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "flac"), .audio)
        XCTAssertEqual(MediaKind.kind(forExtension: "mp4"), .video)
        XCTAssertNil(MediaKind.kind(forExtension: "txt"))
    }
}
```

- [ ] **Step 2: Implement the media item model**

Create `MP3Build/Models/MediaItem.swift`:

```swift
import Foundation

enum MediaKind: String, Codable, Equatable {
    case audio
    case video

    static func kind(forExtension fileExtension: String) -> MediaKind? {
        switch fileExtension.lowercased() {
        case "mp3", "m4a", "aac", "wav", "aiff", "flac":
            return .audio
        case "mp4", "m4v", "mov":
            return .video
        default:
            return nil
        }
    }
}

struct MediaItem: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var artist: String?
    var album: String?
    var filename: String
    var kind: MediaKind
    var duration: TimeInterval?

    init(
        id: UUID = UUID(),
        title: String,
        artist: String? = nil,
        album: String? = nil,
        filename: String,
        kind: MediaKind,
        duration: TimeInterval? = nil
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.filename = filename
        self.kind = kind
        self.duration = duration
    }
}
```

- [ ] **Step 3: Implement screen routing**

Create `MP3Build/Models/PlayerScreen.swift`:

```swift
enum PlayerScreen: Equatable {
    case home
    case nowPlaying
    case music
    case videos
    case settings
}
```

- [ ] **Step 4: Implement the built-in theme**

Create `MP3Build/Models/PlayerTheme.swift`:

```swift
import SwiftUI

struct PlayerTheme: Equatable {
    var name: String
    var bodyTop: Color
    var bodyBottom: Color
    var screenBackground: Color
    var screenGloss: Color
    var primaryText: Color
    var secondaryText: Color
    var focus: Color
    var wheel: Color
    var wheelGlyph: Color

    static let sunburstClassic = PlayerTheme(
        name: "Sunburst Classic",
        bodyTop: Color(red: 1.00, green: 0.78, blue: 0.30),
        bodyBottom: Color(red: 0.91, green: 0.56, blue: 0.12),
        screenBackground: Color(red: 0.04, green: 0.02, blue: 0.10),
        screenGloss: Color(red: 0.08, green: 0.24, blue: 0.35),
        primaryText: .white,
        secondaryText: Color.white.opacity(0.70),
        focus: Color(red: 0.00, green: 0.93, blue: 0.95),
        wheel: Color.white.opacity(0.94),
        wheelGlyph: Color.black.opacity(0.58)
    )
}
```

- [ ] **Step 5: Run tests in Xcode**

Run from Xcode on macOS:

```bash
xcodebuild test -scheme MP3Build -destination 'platform=iOS Simulator,name=iPhone  SE (3rd generation)'
```

Expected: `MediaItemTests.testMediaKindClassifiesCommonExtensions` passes.

- [ ] **Step 6: Commit**

Run:

```bash
git add MP3Build/Models MP3BuildTests
git commit -m "feat: add media and theme models"
```

Expected: commit succeeds.

### Task 3: Library Persistence

**Files:**
- Create: `MP3Build/Services/MediaLibrary.swift`
- Create: `MP3BuildTests/MediaLibraryTests.swift`

- [ ] **Step 1: Write persistence tests**

Create `MP3BuildTests/MediaLibraryTests.swift`:

```swift
import XCTest
@testable import MP3Build

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
```

- [ ] **Step 2: Implement media library persistence**

Create `MP3Build/Services/MediaLibrary.swift`:

```swift
import Foundation

@MainActor
final class MediaLibrary: ObservableObject {
    enum LibraryError: Error, Equatable {
        case unsupportedFile
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
        try fileManager.createDirectory(at: rootDirectory, withIntermediateDirectories: true)
        let item = try makeItem(forImportedFile: sourceURL)
        let destination = rootDirectory.appendingPathComponent(item.filename)

        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }

        try fileManager.copyItem(at: sourceURL, to: destination)
        items.removeAll { $0.filename == item.filename }
        items.append(item)
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
```

- [ ] **Step 3: Run tests in Xcode**

Run:

```bash
xcodebuild test -scheme MP3Build -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation)'
```

Expected: media model and library tests pass.

- [ ] **Step 4: Commit**

Run:

```bash
git add MP3Build/Services/MediaLibrary.swift MP3BuildTests/MediaLibraryTests.swift
git commit -m "feat: persist local media library"
```

Expected: commit succeeds.

### Task 4: Playback Controller

**Files:**
- Create: `MP3Build/Services/PlaybackController.swift`

- [ ] **Step 1: Implement playback state wrapper**

Create `MP3Build/Services/PlaybackController.swift`:

```swift
import AVFoundation
import Foundation

@MainActor
final class PlaybackController: ObservableObject {
    enum PlaybackState: Equatable {
        case stopped
        case playing
        case paused
        case failed(String)
    }

    @Published private(set) var currentItem: MediaItem?
    @Published private(set) var state: PlaybackState = .stopped
    @Published private(set) var player: AVPlayer?

    func play(item: MediaItem, fileURL: URL) {
        currentItem = item
        player = AVPlayer(url: fileURL)
        player?.play()
        state = .playing
    }

    func togglePlayPause() {
        switch state {
        case .playing:
            player?.pause()
            state = .paused
        case .paused, .stopped:
            player?.play()
            state = currentItem == nil ? .stopped : .playing
        case .failed:
            break
        }
    }

    func stop() {
        player?.pause()
        player = nil
        state = .stopped
    }
}
```

- [ ] **Step 2: Run a source review**

Open the file in Xcode and confirm `AVFoundation` resolves for the iOS target.

Expected: no unresolved symbols in `PlaybackController.swift`.

- [ ] **Step 3: Commit**

Run:

```bash
git add MP3Build/Services/PlaybackController.swift
git commit -m "feat: add local playback controller"
```

Expected: commit succeeds.

### Task 5: Navigation Model

**Files:**
- Create: `MP3Build/Services/PlayerNavigationModel.swift`
- Create: `MP3BuildTests/PlayerNavigationModelTests.swift`

- [ ] **Step 1: Write navigation tests**

Create `MP3BuildTests/PlayerNavigationModelTests.swift`:

```swift
import XCTest
@testable import MP3Build

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
```

- [ ] **Step 2: Implement navigation**

Create `MP3Build/Services/PlayerNavigationModel.swift`:

```swift
import Foundation

@MainActor
final class PlayerNavigationModel: ObservableObject {
    struct HomeEntry: Identifiable, Equatable {
        let id = UUID()
        let title: String
        let screen: PlayerScreen
    }

    @Published private(set) var stack: [PlayerScreen] = [.home]
    @Published var selectedHomeIndex: Int = 0

    let homeEntries: [HomeEntry] = [
        HomeEntry(title: "Now Playing", screen: .nowPlaying),
        HomeEntry(title: "Music", screen: .music),
        HomeEntry(title: "Videos", screen: .videos),
        HomeEntry(title: "Settings", screen: .settings)
    ]

    var currentScreen: PlayerScreen {
        stack.last ?? .home
    }

    func moveSelection(delta: Int) {
        guard currentScreen == .home else { return }
        let count = homeEntries.count
        selectedHomeIndex = (selectedHomeIndex + delta + count) % count
    }

    func select() {
        guard currentScreen == .home else { return }
        stack.append(homeEntries[selectedHomeIndex].screen)
    }

    func back() {
        if stack.count > 1 {
            stack.removeLast()
        } else {
            selectedHomeIndex = 0
        }
    }

    func home() {
        stack = [.home]
        selectedHomeIndex = 0
    }
}
```

- [ ] **Step 3: Run tests in Xcode**

Run:

```bash
xcodebuild test -scheme MP3Build -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation)'
```

Expected: navigation tests pass.

- [ ] **Step 4: Commit**

Run:

```bash
git add MP3Build/Services/PlayerNavigationModel.swift MP3BuildTests/PlayerNavigationModelTests.swift
git commit -m "feat: add click wheel navigation model"
```

Expected: commit succeeds.

### Task 6: Device UI and Click Wheel

**Files:**
- Modify: `MP3Build/Views/RootDeviceView.swift`
- Create: `MP3Build/Views/DeviceScreenView.swift`
- Create: `MP3Build/Views/HomeMenuView.swift`
- Create: `MP3Build/Views/ClickWheelView.swift`

- [ ] **Step 1: Replace root shell with injected models**

Update `MP3Build/Views/RootDeviceView.swift`:

```swift
import SwiftUI

struct RootDeviceView: View {
    @StateObject private var library = MediaLibrary()
    @StateObject private var playback = PlaybackController()
    @StateObject private var navigation = PlayerNavigationModel()

    private let theme = PlayerTheme.sunburstClassic

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [theme.bodyTop, theme.bodyBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 26) {
                DeviceScreenView()
                    .environmentObject(library)
                    .environmentObject(playback)
                    .environmentObject(navigation)
                    .environment(\.playerTheme, theme)
                    .frame(height: 226)

                ClickWheelView(
                    onRotate: navigation.moveSelection,
                    onMenu: navigation.back,
                    onSelect: navigation.select,
                    onPrevious: {},
                    onNext: {},
                    onPlayPause: playback.togglePlayPause
                )
                .environment(\.playerTheme, theme)
            }
            .padding(.horizontal, 26)
        }
    }
}

#Preview {
    RootDeviceView()
}
```

- [ ] **Step 2: Add theme environment support**

Append to `MP3Build/Models/PlayerTheme.swift`:

```swift
private struct PlayerThemeKey: EnvironmentKey {
    static let defaultValue = PlayerTheme.sunburstClassic
}

extension EnvironmentValues {
    var playerTheme: PlayerTheme {
        get { self[PlayerThemeKey.self] }
        set { self[PlayerThemeKey.self] = newValue }
    }
}
```

- [ ] **Step 3: Create the screen router**

Create `MP3Build/Views/DeviceScreenView.swift`:

```swift
import SwiftUI

struct DeviceScreenView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(theme.screenBackground)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(theme.screenGloss.opacity(0.72))
                        .frame(width: 190, height: 190)
                        .offset(x: 42, y: -80)
                }

            VStack(spacing: 8) {
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                    Text("||  ♪  ▰")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(theme.primaryText)

                screenBody
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.black.opacity(0.35), lineWidth: 8)
        }
    }

    private var title: String {
        switch navigation.currentScreen {
        case .home: return "Home"
        case .nowPlaying: return "Now Playing"
        case .music: return "Music"
        case .videos: return "Videos"
        case .settings: return "Settings"
        }
    }

    @ViewBuilder
    private var screenBody: some View {
        switch navigation.currentScreen {
        case .home:
            HomeMenuView()
        case .nowPlaying:
            Text("Nothing Playing")
                .foregroundStyle(theme.secondaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .music:
            Text("Music Library")
                .foregroundStyle(theme.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .videos:
            Text("Video Library")
                .foregroundStyle(theme.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .settings:
            Text("Sunburst Classic")
                .foregroundStyle(theme.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
```

- [ ] **Step 4: Create home menu**

Create `MP3Build/Views/HomeMenuView.swift`:

```swift
import SwiftUI

struct HomeMenuView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var navigation: PlayerNavigationModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 9) {
                ForEach(Array(navigation.homeEntries.enumerated()), id: \.offset) { index, entry in
                    HStack(spacing: 8) {
                        Text(entry.title)
                            .font(.system(size: index == navigation.selectedHomeIndex ? 28 : 25, weight: .bold))
                        if index == navigation.selectedHomeIndex {
                            Text(">")
                                .font(.system(size: 26, weight: .bold))
                        }
                    }
                    .foregroundStyle(index == navigation.selectedHomeIndex ? theme.focus : theme.primaryText)
                }
            }

            Spacer()

            ZStack {
                Circle()
                    .fill(.black.opacity(0.38))
                    .frame(width: 92, height: 92)
                Text("♪")
                    .font(.system(size: 58, weight: .black))
                    .foregroundStyle(theme.focus)
            }
        }
    }
}
```

- [ ] **Step 5: Create click wheel**

Create `MP3Build/Views/ClickWheelView.swift`:

```swift
import SwiftUI

struct ClickWheelView: View {
    @Environment(\.playerTheme) private var theme

    var onRotate: (Int) -> Void
    var onMenu: () -> Void
    var onSelect: () -> Void
    var onPrevious: () -> Void
    var onNext: () -> Void
    var onPlayPause: () -> Void

    @State private var lastAngle: Angle?

    var body: some View {
        ZStack {
            Circle()
                .fill(theme.wheel)
                .shadow(color: .black.opacity(0.18), radius: 10, y: 5)
                .gesture(rotationGesture)

            Button(action: onMenu) {
                Text("↩/▦")
                    .font(.system(size: 28, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.wheelGlyph)
            .offset(y: -82)

            Button(action: onPrevious) {
                Text("◀◀")
                    .font(.system(size: 30, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.wheelGlyph)
            .offset(x: -84)

            Button(action: onNext) {
                Text("▶▶")
                    .font(.system(size: 30, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.wheelGlyph)
            .offset(x: 84)

            Button(action: onPlayPause) {
                Text("▶Ⅱ/■")
                    .font(.system(size: 26, weight: .bold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(theme.wheelGlyph)
            .offset(y: 86)

            Button(action: onSelect) {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.bodyTop, theme.bodyBottom],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 96, height: 96)
            }
            .buttonStyle(.plain)
        }
        .frame(width: 266, height: 266)
    }

    private var rotationGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let center = CGPoint(x: 133, y: 133)
                let vector = CGVector(dx: value.location.x - center.x, dy: value.location.y - center.y)
                let angle = Angle(radians: atan2(vector.dy, vector.dx))

                if let lastAngle {
                    let delta = angle.degrees - lastAngle.degrees
                    if abs(delta) > 18 {
                        onRotate(delta > 0 ? 1 : -1)
                        self.lastAngle = angle
                    }
                } else {
                    lastAngle = angle
                }
            }
            .onEnded { _ in
                lastAngle = nil
            }
    }
}
```

- [ ] **Step 6: Run UI preview in Xcode**

Open `RootDeviceView` preview.

Expected: yellow device shell, small dark screen, home menu, and white click wheel appear without clipped text on an iPhone 7-sized preview.

- [ ] **Step 7: Commit**

Run:

```bash
git add MP3Build/Views MP3Build/Models/PlayerTheme.swift
git commit -m "feat: build device shell and click wheel"
```

Expected: commit succeeds.

### Task 7: Import UI, Lists, and Now Playing

**Files:**
- Create: `MP3Build/Views/ImportButton.swift`
- Create: `MP3Build/Views/MediaListView.swift`
- Create: `MP3Build/Views/NowPlayingView.swift`
- Modify: `MP3Build/Views/DeviceScreenView.swift`

- [ ] **Step 1: Create document picker bridge**

Create `MP3Build/Views/ImportButton.swift`:

```swift
import SwiftUI
import UniformTypeIdentifiers

struct ImportButton: UIViewControllerRepresentable {
    var onImport: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let types: [UTType] = [.audio, .movie, .mpeg4Movie, .mp3]
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: types)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImport: onImport)
    }

    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onImport: (URL) -> Void

        init(onImport: @escaping (URL) -> Void) {
            self.onImport = onImport
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            urls.forEach(onImport)
        }
    }
}
```

- [ ] **Step 2: Create media list view**

Create `MP3Build/Views/MediaListView.swift`:

```swift
import SwiftUI

struct MediaListView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var library: MediaLibrary
    @EnvironmentObject private var playback: PlaybackController

    var kind: MediaKind
    @State private var showingImporter = false
    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button("+") {
                    showingImporter = true
                }
                .font(.system(size: 24, weight: .bold))
                .buttonStyle(.plain)
                .foregroundStyle(theme.focus)

                Text(kind == .audio ? "Import Music" : "Import Video")
                    .foregroundStyle(theme.secondaryText)
                    .font(.system(size: 14, weight: .semibold))
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(items) { item in
                        Button {
                            playback.play(item: item, fileURL: library.fileURL(for: item))
                        } label: {
                            Text(item.title)
                                .font(.system(size: 18, weight: .bold))
                                .lineLimit(1)
                                .foregroundStyle(theme.primaryText)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            if let message {
                Text(message)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(theme.focus)
            }
        }
        .sheet(isPresented: $showingImporter) {
            ImportButton { url in
                do {
                    try library.importFile(from: url)
                    message = "Imported \(url.lastPathComponent)"
                } catch {
                    message = "Could not import file"
                }
            }
        }
    }

    private var items: [MediaItem] {
        kind == .audio ? library.audioItems : library.videoItems
    }
}
```

- [ ] **Step 3: Create now playing view**

Create `MP3Build/Views/NowPlayingView.swift`:

```swift
import AVKit
import SwiftUI

struct NowPlayingView: View {
    @Environment(\.playerTheme) private var theme
    @EnvironmentObject private var playback: PlaybackController

    var body: some View {
        VStack(spacing: 10) {
            if let item = playback.currentItem {
                if item.kind == .video, let player = playback.player {
                    VideoPlayer(player: player)
                        .frame(maxWidth: .infinity, maxHeight: 122)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(theme.screenGloss.opacity(0.55))
                        Text("♪")
                            .font(.system(size: 64, weight: .black))
                            .foregroundStyle(theme.focus)
                    }
                    .frame(height: 112)
                }

                Text(item.title)
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(1)
                    .foregroundStyle(theme.primaryText)
            } else {
                Spacer()
                Text("Nothing Playing")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(theme.secondaryText)
                Spacer()
            }
        }
    }
}
```

- [ ] **Step 4: Route lists and now playing**

Update the `screenBody` switch in `MP3Build/Views/DeviceScreenView.swift`:

```swift
    @ViewBuilder
    private var screenBody: some View {
        switch navigation.currentScreen {
        case .home:
            HomeMenuView()
        case .nowPlaying:
            NowPlayingView()
        case .music:
            MediaListView(kind: .audio)
        case .videos:
            MediaListView(kind: .video)
        case .settings:
            Text("Sunburst Classic")
                .foregroundStyle(theme.primaryText)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
```

- [ ] **Step 5: Test manually on device or simulator**

Run the app from Xcode, import one audio file and one MP4 file through the Files picker, tap each item, and open Now Playing.

Expected: audio plays with a music placeholder; MP4 plays inside the embedded screen.

- [ ] **Step 6: Commit**

Run:

```bash
git add MP3Build/Views
git commit -m "feat: add local import and playback views"
```

Expected: commit succeeds.

### Task 8: Final Fit and Documentation

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Add sideloading notes**

Update `README.md`:

```markdown
# MP3 Build

MP3 Build is a local-only SwiftUI media player for iPhone. It uses an Innioasis/iPod-inspired device shell, a small embedded player screen, and a virtual click wheel.

## Build Requirements

- macOS with Xcode
- iOS signing identity or sideloading workflow
- iPhone 7 or compatible simulator/device

## Current Scope

- Local music import
- Local MP4 import
- Music and video library screens
- Playback inside a small device screen
- Virtual click wheel navigation

The app does not emulate Innioasis firmware and does not use proprietary Innioasis assets.

## Building

1. Open `MP3Build.xcodeproj` in Xcode.
2. Select the `MP3Build` scheme.
3. Choose an iPhone simulator or connected iPhone.
4. Build and run.

## Sideloading Direction

To create an IPA, archive the app in Xcode with a valid signing identity, export the archive, then install the IPA through your sideloading workflow. This repository does not include certificates, profiles, or vendor firmware.
```

- [ ] **Step 2: Final verification on macOS**

Run:

```bash
xcodebuild test -scheme MP3Build -destination 'platform=iOS Simulator,name=iPhone SE (3rd generation)'
```

Expected: all tests pass.

- [ ] **Step 3: Final device check**

Run on a physical iPhone 7 or closest simulator and verify:

- Home menu fits inside the screen.
- Click wheel changes selected menu item.
- Center button opens selected screen.
- Menu button returns home.
- Audio import works.
- MP4 import works.
- MP4 video displays inside Now Playing.

- [ ] **Step 4: Commit**

Run:

```bash
git add README.md
git commit -m "docs: add build and sideload notes"
```

Expected: commit succeeds.

## Self-Review

- Spec coverage: The plan covers local import, local audio/video playback, MP4 inside the embedded screen, click wheel controls, Innioasis-inspired original theme styling, persistence, documentation, and the Xcode/macOS build path.
- Placeholder scan: No task contains unresolved placeholder text.
- Type consistency: `MediaItem`, `MediaKind`, `PlayerScreen`, `MediaLibrary`, `PlaybackController`, `PlayerNavigationModel`, and view names are used consistently across tasks.

