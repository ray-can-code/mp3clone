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
