# Local iOS Media Player Design

## Goal

Build a sideloadable iOS app that turns an iPhone 7 into a local-only media player inspired by the Innioasis Y1 and classic iPod-style hardware. The app should feel like a physical MP3/video player: a colored device body, a small screen, and a virtual click wheel that controls the experience.

## Non-Goals

- Do not emulate or run Innioasis firmware.
- Do not copy proprietary Innioasis artwork, icons, binaries, or theme assets.
- Do not require jailbreaking.
- Do not stream media or use cloud services in the first version.
- Do not depend on App Store distribution.

## Platform

The first implementation is a SwiftUI iOS app intended for iPhone 7-class devices. The source can be prepared in this Windows workspace, but producing a signed IPA will require macOS/Xcode or a cloud macOS build service.

## Core Experience

The app opens directly into a full-screen device shell. The iPhone screen shows an MP3-player-like body with a small embedded screen at the top and a click wheel below it. All primary app navigation happens inside that embedded screen.

The embedded screen presents a simple media-player operating system:

- Home
- Now Playing
- Music
- Videos
- Settings

The visual language should be inspired by the supplied Innioasis reference image and public Y1 theme structure: dark glossy screen, high-contrast text, cyan focus highlight, small status icons, and animated menu transitions. The app will use original local assets and a local JSON-backed theme model.

## Media Support

The app stores imported media locally inside its app container. Version 1 supports:

- Music playback for local audio files supported by iOS playback APIs.
- MP4 video playback inside the embedded device screen.
- Separate Music and Videos library screens.
- A Now Playing screen that shows either track metadata or an inline video player.
- Basic transport controls: play, pause, previous, next, seek.

Import uses the iOS document picker so the user can choose files from the Files app. Export is limited to iOS-supported file sharing behavior for the app's Documents folder.

## Click Wheel Controls

The click wheel is both visual and functional:

- Dragging around the wheel moves menu selection up or down.
- Center button selects the focused item.
- Top button goes back or home.
- Left and right buttons skip or seek depending on the current screen.
- Bottom button toggles play and pause.

The wheel should provide immediate visual feedback when pressed or dragged.

## Theme System

The first build includes one built-in theme named `Sunburst Classic`, based on the yellow device reference. Theme data is local and structured so later themes can be added without rewriting the player:

- Device body colors.
- Screen colors.
- Focus highlight color.
- Text colors.
- Status icon colors.
- Transition timing.

The structure should resemble the public Innioasis theme idea of image/config-driven themes, but remain native Swift data for the initial app.

## Architecture

The app uses a small set of focused SwiftUI files:

- App entry point.
- Root device shell.
- Embedded screen router.
- Menu screens.
- Now playing screen.
- Click wheel control.
- Media library model.
- Playback controller.
- Import controller.
- Theme model.

State flows through observable models:

- `MediaLibrary` owns imported media records.
- `PlaybackController` owns current item and playback state.
- `PlayerNavigationModel` owns screen stack and menu selection.
- `ThemeStore` provides the active theme.

## Persistence

Imported files are copied into the app's Documents directory. Metadata is stored in a local JSON file next to the imported library. The app should be able to rebuild missing metadata from files if the JSON index is absent.

## Error Handling

If import fails, show a short in-screen alert inside the device screen. If playback fails, keep the app usable, stop playback, and show a short message. Unsupported files should be skipped with a clear error rather than crashing.

## Testing and Verification

Because the current workspace is Windows-based, local verification focuses on source structure, syntax review, deterministic model tests where possible, and a clear Xcode build path. On macOS, the app should be tested on an iPhone 7 or iOS simulator for:

- Importing audio and MP4 files.
- Playing local audio.
- Playing MP4 video inside the embedded screen.
- Navigating all screens with the click wheel.
- Confirming UI fits an iPhone 7 display.

