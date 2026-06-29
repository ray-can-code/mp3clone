# Minecraft Theme Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add the provided Innioasis Minecraft theme as MP3 Build's default iOS emulator skin.

**Architecture:** Copy selected theme assets into app resources, add a font registration helper, extend the theme model with asset names and home menu entries, then update SwiftUI views to render the Minecraft wallpaper, pixel font, selected-row art, menu icons, status strip, and silver click wheel.

**Tech Stack:** Swift 5, SwiftUI, CoreText, Xcode resources, XCTest.

---

## File Structure

- Create `MP3Build/Resources/Themes/Minecraft/*`: selected PNG and TTF assets from the user-provided theme zip.
- Create `MP3Build/Services/FontRegistry.swift`: registers bundled theme fonts.
- Modify `MP3Build/MP3BuildApp.swift`: register fonts before rendering.
- Modify `MP3Build/Models/PlayerTheme.swift`: add Minecraft theme asset tokens.
- Modify `MP3Build/Models/PlayerScreen.swift`: add placeholder routes.
- Modify `MP3Build/Services/PlayerNavigationModel.swift`: map Minecraft-style menu entries.
- Modify `MP3Build/Views/*.swift`: render Minecraft theme visuals.
- Modify `MP3Build.xcodeproj/project.pbxproj`: include resources and new Swift file.
- Add/modify tests for theme default and menu mapping.

## Tasks

- [ ] Add theme assets from `Minecraft.zip` to `MP3Build/Resources/Themes/Minecraft`.
- [ ] Add a failing test that expects the default theme to be `Minecraft`.
- [ ] Add a failing test that expects the home menu to include the Minecraft-style entries.
- [ ] Implement theme tokens and font registration.
- [ ] Update home/menu/screen/click-wheel views to use the Minecraft visual system.
- [ ] Update Xcode project resources and source file references.
- [ ] Verify the project structure locally and push for GitHub Actions Xcode verification.

## Self-Review

- Spec coverage: Covers asset bundling, font, wallpaper, selected row, menu icons, status bar, silver body, click wheel, default theme, and preservation of player behavior.
- Placeholder scan: Placeholder screens are intentional functional routes for unimplemented Y1-style features.
- Type consistency: `PlayerTheme.minecraft`, `ThemeHomeEntry`, `PlayerScreen`, and `FontRegistry` are the names used by the implementation tasks.
