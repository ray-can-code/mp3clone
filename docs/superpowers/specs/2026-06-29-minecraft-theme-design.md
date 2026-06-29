# Minecraft Theme Design

## Goal

Rebuild the provided Innioasis Minecraft theme inside MP3 Build as the default visual theme for the sideloaded iOS media-player emulator.

## Inputs

Use the local theme package supplied by the user:

- `Minecraft.zip`
- Screenshots showing the Y1/Y2 theme preview in use

The zip contains a complete Innioasis theme with `config.json`, `minecraft.ttf`, wallpaper, selected-row backgrounds, right-arrow art, home-screen icons, and status icons.

## Visual Direction

The app should resemble the reference screenshots:

- Silver/white rounded device shell.
- Small dark screen with Minecraft landscape wallpaper.
- Pixel font for screen text.
- White menu text over a dimmed wallpaper.
- Light gray selected menu rectangle with dark pixel text.
- Small right arrow inside the selected row.
- Large pixel-art icon on the right side that changes with the selected menu item.
- Top-right battery indicator with `100%`.
- Silver click wheel with blue transport buttons and `BACK` at the top.

## Functional Mapping

The home menu keeps the app's real features first and includes placeholder entries for theme completeness:

- Now Playing
- Music
- Videos
- Audiobooks
- Photos
- FM Radio
- Bluetooth
- Settings

`Now Playing`, `Music`, `Videos`, and `Settings` keep their existing behavior. Placeholder entries can open simple placeholder screens until those features are implemented.

## Architecture

Add a lightweight theme asset layer:

- Bundle selected Minecraft theme assets as app resources.
- Register the bundled Minecraft font at app startup.
- Extend `PlayerTheme` to support named image assets and selected-row styling.
- Update `RootDeviceView`, `DeviceScreenView`, `HomeMenuView`, `ClickWheelView`, and `SettingsView` to render from theme tokens instead of hardcoded Sunburst values.
- Make `PlayerTheme.minecraft` the default theme.

## Constraints

- Keep all assets local.
- Do not require network access at runtime.
- Do not remove the existing Sunburst theme code.
- Preserve current import, playback, and cloud-build workflow behavior.
- Keep text readable on iPhone 7-sized displays.
