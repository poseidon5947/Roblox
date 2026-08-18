#!/usr/bin/env python3
"""
Pack SoftPhoneUI Lua sources into a Studio-openable .rbxlx demo place
and a reusable .rbxmx model package.
"""

from __future__ import annotations

import html
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MODULES = ROOT / "src" / "ReplicatedStorage" / "SoftPhoneModules"
STARTER = ROOT / "src" / "StarterGui" / "SoftPhoneUI"
OUT_PLACE = ROOT / "SoftPhoneUI_Demo.rbxlx"
OUT_MODEL = ROOT / "SoftPhoneUI_Package.rbxmx"
OUT_PLACE_UPDATED = ROOT / "SoftPhoneUI_Demo_Updated.rbxlx"
OUT_MODEL_UPDATED = ROOT / "SoftPhoneUI_Package_Updated.rbxmx"
OUT_PLACE_LATEST = ROOT / "SoftPhoneUI_Demo_v2_19_FeedbackPolish.rbxlx"
OUT_MODEL_LATEST = ROOT / "SoftPhoneUI_Package_v2_19_FeedbackPolish.rbxmx"

MODULE_FILES = [
    "Theme.lua",
    "TweenUtil.lua",
    "IconDraw.lua",
    "NotificationCenter.lua",
    "Sidebar.lua",
    "WindowChrome.lua",
    "ShopWindow.lua",
    "PlaceholderWindows.lua",
    "WindowManager.lua",
]


def cdata(source: str) -> str:
    if "]]>" in source:
        source = source.replace("]]>", "]]]]><![CDATA[>")
    return f"<![CDATA[{source}]]>"


def module_item(name: str, source: str) -> str:
    return f"""    <Item class="ModuleScript" referent="MS_{name}">
      <Properties>
        <string name="Name">{html.escape(name)}</string>
        <ProtectedString name="Source">{cdata(source)}</ProtectedString>
      </Properties>
    </Item>
"""


def local_script_item(name: str, source: str) -> str:
    return f"""      <Item class="LocalScript" referent="LS_{name}">
        <Properties>
          <string name="Name">{html.escape(name)}</string>
          <ProtectedString name="Source">{cdata(source)}</ProtectedString>
          <bool name="Disabled">false</bool>
        </Properties>
      </Item>
"""


def static_launcher_item() -> str:
    return """      <Item class="TextButton" referent="StaticEdgeLauncher">
        <Properties>
          <string name="Name">StaticEdgeLauncher</string>
          <bool name="Active">true</bool>
          <bool name="AutoButtonColor">false</bool>
          <Color3 name="BackgroundColor3"><R>1</R><G>0.827451</G><B>0.913725</B></Color3>
          <float name="BackgroundTransparency">0</float>
          <int name="BorderSizePixel">0</int>
          <Vector2 name="AnchorPoint"><X>1</X><Y>0.5</Y></Vector2>
          <UDim2 name="Position"><XS>1</XS><XO>-6</XO><YS>0.5</YS><YO>0</YO></UDim2>
          <UDim2 name="Size"><XS>0</XS><XO>42</XO><YS>0</YS><YO>240</YO></UDim2>
          <string name="Text">FURU
PHONE</string>
          <Color3 name="TextColor3"><R>0.909804</R><G>0.372549</G><B>0.65098</B></Color3>
          <float name="TextSize">11</float>
          <bool name="TextWrapped">true</bool>
          <token name="Font">18</token>
          <int name="ZIndex">900</int>
        </Properties>
        <Item class="UICorner" referent="StaticEdgeLauncherCorner">
          <Properties>
            <string name="Name">Corner</string>
            <UDim name="CornerRadius"><S>0</S><O>14</O></UDim>
          </Properties>
        </Item>
        <Item class="UIStroke" referent="StaticEdgeLauncherStroke">
          <Properties>
            <string name="Name">Stroke</string>
            <Color3 name="Color"><R>1</R><G>1</G><B>1</B></Color3>
            <float name="Thickness">2</float>
          </Properties>
        </Item>
      </Item>
"""


def load_modules() -> str:
    chunks = []
    for filename in MODULE_FILES:
        path = MODULES / filename
        chunks.append(module_item(path.stem, path.read_text(encoding="utf-8-sig")))
    return "\n".join(chunks)


def load_bootstrap() -> str:
    candidates = [
        STARTER / "SoftPhoneBootstrap.client.lua",
        STARTER / "SoftPhoneBootstrap.lua",
    ]
    for path in candidates:
        if path.exists():
            return path.read_text(encoding="utf-8-sig")
    raise FileNotFoundError("SoftPhoneBootstrap script not found")


def build_place(modules_xml: str, bootstrap: str) -> str:
    return f"""<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
  <Item class="Workspace" referent="Workspace">
    <Properties>
      <string name="Name">Workspace</string>
    </Properties>
    <Item class="Part" referent="Baseplate">
      <Properties>
        <string name="Name">Baseplate</string>
        <bool name="Anchored">true</bool>
        <Vector3 name="Size"><X>512</X><Y>1</Y><Z>512</Z></Vector3>
        <CoordinateFrame name="CFrame"><X>0</X><Y>-0.5</Y><Z>0</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame>
        <Color3uint8 name="Color3uint8">217167242</Color3uint8>
        <token name="Material">256</token>
      </Properties>
    </Item>
    <Item class="SpawnLocation" referent="Spawn">
      <Properties>
        <string name="Name">SpawnLocation</string>
        <bool name="Anchored">true</bool>
        <float name="Duration">0</float>
        <Vector3 name="Size"><X>12</X><Y>1</Y><Z>12</Z></Vector3>
        <CoordinateFrame name="CFrame"><X>0</X><Y>0.5</Y><Z>0</Z><R00>1</R00><R01>0</R01><R02>0</R02><R10>0</R10><R11>1</R11><R12>0</R12><R20>0</R20><R21>0</R21><R22>1</R22></CoordinateFrame>
        <Color3uint8 name="Color3uint8">255096181</Color3uint8>
      </Properties>
    </Item>
  </Item>
  <Item class="Lighting" referent="Lighting">
    <Properties>
      <string name="Name">Lighting</string>
      <float name="Brightness">2</float>
      <Color3 name="Ambient"><R>0.78</R><G>0.70</G><B>0.82</B></Color3>
      <Color3 name="OutdoorAmbient"><R>0.65</R><G>0.58</G><B>0.72</B></Color3>
    </Properties>
  </Item>
  <Item class="ReplicatedStorage" referent="ReplicatedStorage">
    <Properties>
      <string name="Name">ReplicatedStorage</string>
    </Properties>
    <Item class="Folder" referent="SoftPhoneModules">
      <Properties>
        <string name="Name">SoftPhoneModules</string>
      </Properties>
{modules_xml}
    </Item>
    <Item class="Folder" referent="SoftPhoneWearables">
      <Properties>
        <string name="Name">SoftPhoneWearables</string>
      </Properties>
    </Item>
  </Item>
  <Item class="StarterGui" referent="StarterGui">
    <Properties>
      <string name="Name">StarterGui</string>
    </Properties>
    <Item class="ScreenGui" referent="SoftPhoneUI">
      <Properties>
        <string name="Name">SoftPhoneUI</string>
        <bool name="ResetOnSpawn">false</bool>
        <bool name="IgnoreGuiInset">true</bool>
        <bool name="Enabled">true</bool>
        <int name="DisplayOrder">100</int>
        <token name="ZIndexBehavior">1</token>
      </Properties>
{static_launcher_item()}
{local_script_item("SoftPhoneBootstrap", bootstrap)}
    </Item>
  </Item>
  <Item class="StarterPlayer" referent="StarterPlayer">
    <Properties>
      <string name="Name">StarterPlayer</string>
    </Properties>
    <Item class="StarterPlayerScripts" referent="StarterPlayerScripts">
      <Properties>
        <string name="Name">StarterPlayerScripts</string>
      </Properties>
    </Item>
  </Item>
  <Item class="Players" referent="Players">
    <Properties>
      <string name="Name">Players</string>
      <token name="CharacterAutoLoads">1</token>
    </Properties>
  </Item>
</roblox>
"""


def build_model(modules_xml: str, bootstrap: str) -> str:
    return f"""<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
  <Item class="Folder" referent="SoftPhonePackage">
    <Properties>
      <string name="Name">SoftPhonePackage</string>
    </Properties>
    <Item class="Folder" referent="SoftPhoneModules">
      <Properties>
        <string name="Name">SoftPhoneModules</string>
      </Properties>
{modules_xml}
    </Item>
    <Item class="Folder" referent="SoftPhoneWearables">
      <Properties>
        <string name="Name">SoftPhoneWearables</string>
      </Properties>
    </Item>
    <Item class="ScreenGui" referent="SoftPhoneUI">
      <Properties>
        <string name="Name">SoftPhoneUI</string>
        <bool name="ResetOnSpawn">false</bool>
        <bool name="IgnoreGuiInset">true</bool>
        <bool name="Enabled">true</bool>
        <int name="DisplayOrder">100</int>
        <token name="ZIndexBehavior">1</token>
      </Properties>
{static_launcher_item()}
{local_script_item("SoftPhoneBootstrap", bootstrap)}
    </Item>
    <Item class="Script" referent="InstallNote">
      <Properties>
        <string name="Name">_INSTALL</string>
        <bool name="Disabled">true</bool>
        <ProtectedString name="Source">{cdata('''-- SoftPhoneUI install
-- 1. Move SoftPhoneModules into ReplicatedStorage
-- 2. Move SoftPhoneWearables into ReplicatedStorage
-- 3. Move SoftPhoneUI ScreenGui into StarterGui
-- 4. Delete this SoftPhonePackage folder
-- 5. Play (F5) - click the gem on the edge tab
''')}</ProtectedString>
      </Properties>
    </Item>
  </Item>
</roblox>
"""


def main():
    modules_xml = load_modules()
    bootstrap = load_bootstrap()
    place_xml = build_place(modules_xml, bootstrap)
    model_xml = build_model(modules_xml, bootstrap)
    OUT_PLACE.write_text(place_xml, encoding="utf-8")
    OUT_MODEL.write_text(model_xml, encoding="utf-8")
    OUT_PLACE_UPDATED.write_text(place_xml, encoding="utf-8")
    OUT_MODEL_UPDATED.write_text(model_xml, encoding="utf-8")
    OUT_PLACE_LATEST.write_text(place_xml, encoding="utf-8")
    OUT_MODEL_LATEST.write_text(model_xml, encoding="utf-8")
    print(f"Wrote {OUT_PLACE}")
    print(f"Wrote {OUT_MODEL}")
    print(f"Wrote {OUT_PLACE_UPDATED}")
    print(f"Wrote {OUT_MODEL_UPDATED}")
    print(f"Wrote {OUT_PLACE_LATEST}")
    print(f"Wrote {OUT_MODEL_LATEST}")


if __name__ == "__main__":
    main()
