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

## No-Mac Build Path

This repository includes a GitHub Actions workflow at `.github/workflows/ios-cloud-build.yml`. Push the repository to GitHub, open the Actions tab, run **iOS Cloud Build**, then download the `MP3Build-unsigned-ipa` artifact.

The artifact is intentionally unsigned. On Windows, use Sideloadly to sign and install the IPA with your Apple ID. If that path fails, the next-best option is Codemagic with Apple code signing configured.
