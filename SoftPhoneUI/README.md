# SoftPhoneUI

White futuristic flip-phone sidebar and six `.exe`-style feature windows for Roblox.

## Included

| Path | Purpose |
|---|---|
| `SoftPhoneUI_Demo.rbxlx` | Studio-openable demo place. Open it, press Play, click the gem. |
| `SoftPhoneUI_Package.rbxmx` | Insertable model package with modules and ScreenGui. |
| `src/` | Rojo-style source tree. |
| `assets/icons/*.svg` | Editable vector icon sources. |
| `assets/png/*.png` | 128x128 PNG icons for Roblox upload. |
| `assets/generated/softphone_icon_sheet.png` | Generated glossy gem/app icon concept sheet. |
| `assets/generated/split/*.png` | Cropped generated PNG drafts for upload to Roblox. |
| `preview/` | Browser motion/layout mock for quick review. |

## Behavior

- The sidebar is always partly visible as a slim outer frame on the screen edge.
- Click the gem in the middle of the tab to slide open or retract.
- The phone panel adds a slight pivot during the slide for a clamshell feel.
- Buttons open dedicated windows for Shop, Gacha, Map, Messages, Teleport, and Job.
- Only one feature window is active at a time.
- Windows slide in and dismiss from the same side as the sidebar.
- Shop shows the local player's R15 avatar in a centered `ViewportFrame`.

## Studio Install

1. Insert `SoftPhoneUI_Package.rbxmx` into your existing place.
2. Move `SoftPhoneModules` into `ReplicatedStorage`.
3. Move `SoftPhoneUI` into `StarterGui`.
4. Delete the wrapper `SoftPhonePackage` folder.
5. Press Play and click the gem on the edge tab.

## Hierarchy

```text
ReplicatedStorage
  SoftPhoneModules
    Theme
    TweenUtil
    IconDraw
    Sidebar
    WindowChrome
    ShopWindow
    PlaceholderWindows
    WindowManager
StarterGui
  SoftPhoneUI
    SoftPhoneBootstrap
    WindowHost        created at runtime
    SidebarRoot       created at runtime
```

## Customization

- Change the sidebar edge in `src/ReplicatedStorage/SoftPhoneModules/Theme.lua`:

```lua
Theme.Side = "Left" -- or "Right"
```

- The runtime already draws no-text glossy icons from Roblox UI primitives.
- Upload generated PNGs from `assets/generated/split/`, then paste their asset ids into `Theme.IconImages`.
- Hook Shop item buttons to your catalog IDs or `HumanoidDescription` pipeline.
- Replace the Gacha, Map, Messages, Teleport, and Job shell bodies in `PlaceholderWindows.lua`.

```lua
Theme.IconImages = {
	gem = "rbxassetid://...",
	bag = "rbxassetid://...",
	star = "rbxassetid://...",
	map = "rbxassetid://...",
	mail = "rbxassetid://...",
	portal = "rbxassetid://...",
	briefcase = "rbxassetid://...",
}
```

## Regenerate

```bash
node tools/generate_icons.mjs
node tools/pack_place.mjs
```

Python equivalents are also included, but this Windows environment currently points `python`/`py` at an inaccessible Store shim.

## Notes

- This workspace generates `.rbxmx` and `.rbxlx` XML files. A binary `.rbxm` requires Roblox Studio: right-click the inserted `SoftPhonePackage` model and choose Save to File.
- `furusatorobloxexport.obj` is a world mesh export and is not required by the UI.
- Layout uses scale plus min/max constraints for desktop, tablet, and phone viewports.
