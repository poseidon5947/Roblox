# SoftPhoneUI

White futuristic flip-phone sidebar and six `.exe`-style feature windows for Roblox.

## Included

| Path | Purpose |
|---|---|
| `SoftPhoneUI_Demo.rbxlx` | Studio-openable demo place. Open it, press Play, click the gem. |
| `SoftPhoneUI_Demo_v2_6_Complete.rbxlx` | Previous complete Studio demo with polished sidebar, shop, and dashboards. |
| `SoftPhoneUI_Demo_v2_7_DressUp.rbxlx` | Previous sample-geometry dress-up experiment. |
| `SoftPhoneUI_Demo_v2_8_UIComplete.rbxlx` | Previous UI-complete demo; exact 3D wearables can be connected later. |
| `SoftPhoneUI_Demo_v2_9_ShopUX.rbxlx` | Previous demo with searchable, filterable shop browsing. |
| `SoftPhoneUI_Demo_v2_10_WindowFix.rbxlx` | Previous fixed demo with working feature windows. |
| `SoftPhoneUI_Demo_v2_11_WearableReady.rbxlx` | Previous demo with exact Accessory try-on integration. |
| `SoftPhoneUI_Demo_v2_12_AppPolish.rbxlx` | Previous demo with reliable startup and stateful feature apps. |
| `SoftPhoneUI_Demo_v2_13_FinalPolish.rbxlx` | Latest client-facing polish, compact Shop pricing, and synchronized badges. |
| `SoftPhoneUI_Package.rbxmx` | Insertable model package with modules and ScreenGui. |
| `src/` | Rojo-style source tree. |
| `assets/icons/*.svg` | Editable vector icon sources. |
| `assets/png/*.png` | 128x128 PNG icons for Roblox upload. |
| `assets/generated/softphone_icon_sheet.png` | Generated glossy gem/app icon concept sheet. |
| `assets/generated/split/*.png` | Cropped generated PNG drafts for upload to Roblox. |
| `assets/generated/decorations/*.png` | Transparent bow and gem decoration PNGs for preview/upload. |
| `preview/` | Browser motion/layout mock for quick review. |

## Behavior

- The sidebar is always partly visible as a slim outer frame on the screen edge.
- Click the gem in the middle of the tab to slide open or retract.
- The phone panel adds a slight pivot during the slide for a clamshell feel.
- Buttons open dedicated windows for Shop, Gacha, Map, Messages, Teleport, and Job.
- Only one feature window is active at a time.
- Windows slide in and dismiss from the same side as the sidebar.
- Shop shows the local player's R15 avatar in a centered `ViewportFrame`.
- Gacha, Map, Messages, Teleport, and Job keep useful local interaction state.
- Mobile windows expand to use available space while Gacha remains full-screen.
- Opening Gacha retracts the sidebar, and message reads update its unread badge.
- Shop search has a clear control and compact item cards retain their prices.

## Studio Install

1. Insert the latest `SoftPhoneUI_Package_v2_13_FinalPolish.rbxmx` into your existing place.
2. Move `SoftPhoneModules` into `ReplicatedStorage`.
3. Move `SoftPhoneWearables` into `ReplicatedStorage`.
4. Move `SoftPhoneUI` into `StarterGui`.
5. Delete the wrapper `SoftPhonePackage` folder.
6. Press Play and click the gem on the edge tab.

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
  SoftPhoneWearables
    pixel_bow_jacket    optional imported Accessory
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
- Decoration PNGs live in `assets/generated/decorations/`; the Roblox runtime also draws native bow/gem decorations without uploads.
- Put finished layered-clothing Accessories in `ReplicatedStorage/SoftPhoneWearables`.
- Name each Accessory after its shop key, such as `pixel_bow_jacket`.
- The shop automatically clones a matching Accessory onto its preview avatar.
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

```lua
Theme.DecorationImages = {
	gemHeart = "rbxassetid://124977509470211",
	bowHeart = "rbxassetid://71160719370388",
	bowOval = "rbxassetid://74233855824346",
	gemDiamond = "rbxassetid://93207797663861",
}
```

## Regenerate

```bash
node tools/generate_icons.mjs
node tools/pack_place.mjs
```

Python equivalents are also included, but this Windows environment currently points `python`/`py` at an inaccessible Store shim.

## Exact 3D Try-On

1. Import the prepared FBX or GLB using Studio's 3D Importer.
2. Convert it with Avatar Setup as `Layered` clothing of type `Jacket`.
3. Name the resulting Accessory `pixel_bow_jacket`.
4. Parent it to `ReplicatedStorage/SoftPhoneWearables`.
5. Open Shop and press `Apply Preview`; the badge changes to `3D TRY-ON` when it loads successfully.

Raw `.obj`, `.fbx`, and `.glb` files in `assets/3D Models` are source files only. Roblox Studio must import and convert them before the runtime UI can use them.

## Notes

- This workspace generates `.rbxmx` and `.rbxlx` XML files. A binary `.rbxm` requires Roblox Studio: right-click the inserted `SoftPhonePackage` model and choose Save to File.
- `furusatorobloxexport.obj` is a world mesh export and is not required by the UI.
- Layout uses scale plus min/max constraints for desktop, tablet, and phone viewports.
