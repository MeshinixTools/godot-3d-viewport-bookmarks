# Godot 3D Viewport Bookmarks

Unreal-style camera bookmarks for Godot's 3D editor viewport. Save up to 10 camera positions and jump between them with one click — no more re-navigating from scratch every time you switch areas of your level.

## Why

Godot's built-in bookmarks work on script lines, not the 3D viewport. If you're doing level design and constantly jumping between regions, you know the pain. This plugin fills that gap.

## Features

- 10 slots, each with a Save (S) and Load (L) button
- Works with the **native 3D editor viewport** — no extra viewport to manage
- Per-project storage, saved automatically
- Godot 4.x

## Installation

### From Godot Asset Library (recommended)

1. Open the **AssetLib** tab in Godot
2. Search for "3D Viewport Bookmarks"
3. Install and enable it in `Project → Project Settings → Plugins`

### Manual

1. Download the latest release
2. Copy the `addons/3d_viewport_bookmarks/` folder into your project's `addons/` folder
3. Enable it in `Project → Project Settings → Plugins`

## Usage

1. Open the 3D editor viewport
2. Move the camera to a viewpoint you want to remember
3. Click `S1` — the slot lights up
4. Move elsewhere
5. Click `L1` — the camera jumps back instantly

Re-pressing `S` overwrites the slot. `L` is disabled while the slot is empty.

## Storage

Bookmarks are saved per-project in `addons/3d_viewport_bookmarks/bookmarks.json`.

## Compatibility

- Godot 4.x
- Godot 3.x: not supported

## License

MIT
