#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = dirname(dirname(fileURLToPath(import.meta.url)));
const MODULES = join(ROOT, "src", "ReplicatedStorage", "SoftPhoneModules");
const STARTER = join(ROOT, "src", "StarterGui", "SoftPhoneUI");
const OUT_PLACE = join(ROOT, "SoftPhoneUI_Demo.rbxlx");
const OUT_MODEL = join(ROOT, "SoftPhoneUI_Package.rbxmx");
const OUT_PLACE_UPDATED = join(ROOT, "SoftPhoneUI_Demo_Updated.rbxlx");
const OUT_MODEL_UPDATED = join(ROOT, "SoftPhoneUI_Package_Updated.rbxmx");
const OUT_PLACE_LATEST = join(ROOT, "SoftPhoneUI_Demo_v2_14_ReleasePolish.rbxlx");
const OUT_MODEL_LATEST = join(ROOT, "SoftPhoneUI_Package_v2_14_ReleasePolish.rbxmx");

const MODULE_FILES = [
  "Theme.lua",
  "TweenUtil.lua",
  "IconDraw.lua",
  "Sidebar.lua",
  "WindowChrome.lua",
  "ShopWindow.lua",
  "PlaceholderWindows.lua",
  "WindowManager.lua",
];

function escapeXml(text) {
  return text.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function cdata(source) {
  return `<![CDATA[${source.replaceAll("]]>", "]]]]><![CDATA[>")}]]>`;
}

function readLua(path) {
  return readFileSync(path, "utf8").replace(/^\uFEFF/, "");
}

function moduleItem(name, source) {
  return `    <Item class="ModuleScript" referent="MS_${name}">
      <Properties>
        <string name="Name">${escapeXml(name)}</string>
        <ProtectedString name="Source">${cdata(source)}</ProtectedString>
      </Properties>
    </Item>
`;
}

function localScriptItem(name, source) {
  return `      <Item class="LocalScript" referent="LS_${name}">
        <Properties>
          <string name="Name">${escapeXml(name)}</string>
          <ProtectedString name="Source">${cdata(source)}</ProtectedString>
          <bool name="Disabled">false</bool>
        </Properties>
      </Item>
`;
}

function loadModules() {
  return MODULE_FILES.map((filename) => {
    const name = filename.replace(/\.lua$/, "");
    return moduleItem(name, readLua(join(MODULES, filename)));
  }).join("\n");
}

function loadBootstrap() {
  return readLua(join(STARTER, "SoftPhoneBootstrap.client.lua"));
}

function staticLauncherItem(indent = "      ") {
  return `${indent}<Item class="TextButton" referent="StaticEdgeLauncher">
${indent}  <Properties>
${indent}    <string name="Name">StaticEdgeLauncher</string>
${indent}    <bool name="Active">true</bool>
${indent}    <bool name="AutoButtonColor">false</bool>
${indent}    <Color3 name="BackgroundColor3"><R>1</R><G>0.827451</G><B>0.913725</B></Color3>
${indent}    <float name="BackgroundTransparency">0</float>
${indent}    <int name="BorderSizePixel">0</int>
${indent}    <Vector2 name="AnchorPoint"><X>1</X><Y>0.5</Y></Vector2>
${indent}    <UDim2 name="Position"><XS>1</XS><XO>-6</XO><YS>0.5</YS><YO>0</YO></UDim2>
${indent}    <UDim2 name="Size"><XS>0</XS><XO>42</XO><YS>0</YS><YO>240</YO></UDim2>
${indent}    <string name="Text">FURU\nPHONE</string>
${indent}    <Color3 name="TextColor3"><R>0.909804</R><G>0.372549</G><B>0.65098</B></Color3>
${indent}    <float name="TextSize">11</float>
${indent}    <bool name="TextWrapped">true</bool>
${indent}    <token name="Font">18</token>
${indent}    <int name="ZIndex">900</int>
${indent}  </Properties>
${indent}  <Item class="UICorner" referent="StaticEdgeLauncherCorner">
${indent}    <Properties>
${indent}      <string name="Name">Corner</string>
${indent}      <UDim name="CornerRadius"><S>0</S><O>14</O></UDim>
${indent}    </Properties>
${indent}  </Item>
${indent}  <Item class="UIStroke" referent="StaticEdgeLauncherStroke">
${indent}    <Properties>
${indent}      <string name="Name">Stroke</string>
${indent}      <Color3 name="Color"><R>1</R><G>1</G><B>1</B></Color3>
${indent}      <float name="Thickness">2</float>
${indent}    </Properties>
${indent}  </Item>
${indent}</Item>`;
}

function buildPlace(modulesXml, bootstrap) {
  return `<?xml version="1.0" encoding="utf-8"?>
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
    <Properties><string name="Name">ReplicatedStorage</string></Properties>
    <Item class="Folder" referent="SoftPhoneModules">
      <Properties><string name="Name">SoftPhoneModules</string></Properties>
${modulesXml}
    </Item>
    <Item class="Folder" referent="SoftPhoneWearables">
      <Properties><string name="Name">SoftPhoneWearables</string></Properties>
    </Item>
  </Item>
  <Item class="StarterGui" referent="StarterGui">
    <Properties><string name="Name">StarterGui</string></Properties>
    <Item class="ScreenGui" referent="SoftPhoneUI">
      <Properties>
        <string name="Name">SoftPhoneUI</string>
        <bool name="ResetOnSpawn">false</bool>
        <bool name="IgnoreGuiInset">true</bool>
        <bool name="Enabled">true</bool>
        <int name="DisplayOrder">100</int>
        <token name="ZIndexBehavior">1</token>
      </Properties>
${staticLauncherItem()}
${localScriptItem("SoftPhoneBootstrap", bootstrap)}
    </Item>
  </Item>
  <Item class="StarterPlayer" referent="StarterPlayer">
    <Properties><string name="Name">StarterPlayer</string></Properties>
    <Item class="StarterPlayerScripts" referent="StarterPlayerScripts">
      <Properties><string name="Name">StarterPlayerScripts</string></Properties>
    </Item>
  </Item>
  <Item class="Players" referent="Players">
    <Properties>
      <string name="Name">Players</string>
      <token name="CharacterAutoLoads">1</token>
    </Properties>
  </Item>
</roblox>
`;
}

function buildModel(modulesXml, bootstrap) {
  const note = `-- SoftPhoneUI install
-- 1. Move SoftPhoneModules into ReplicatedStorage
-- 2. Move SoftPhoneWearables into ReplicatedStorage
-- 3. Move SoftPhoneUI ScreenGui into StarterGui
-- 4. Delete this SoftPhonePackage folder
-- 5. Play (F5) - click the gem on the edge tab
`;
  return `<?xml version="1.0" encoding="utf-8"?>
<roblox xmlns:xmime="http://www.w3.org/2005/05/xmlmime" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="http://www.roblox.com/roblox.xsd" version="4">
  <Item class="Folder" referent="SoftPhonePackage">
    <Properties><string name="Name">SoftPhonePackage</string></Properties>
    <Item class="Folder" referent="SoftPhoneModules">
      <Properties><string name="Name">SoftPhoneModules</string></Properties>
${modulesXml}
    </Item>
    <Item class="Folder" referent="SoftPhoneWearables">
      <Properties><string name="Name">SoftPhoneWearables</string></Properties>
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
${staticLauncherItem()}
${localScriptItem("SoftPhoneBootstrap", bootstrap)}
    </Item>
    <Item class="Script" referent="InstallNote">
      <Properties>
        <string name="Name">_INSTALL</string>
        <bool name="Disabled">true</bool>
        <ProtectedString name="Source">${cdata(note)}</ProtectedString>
      </Properties>
    </Item>
  </Item>
</roblox>
`;
}

const modulesXml = loadModules();
const bootstrap = loadBootstrap();
const placeXml = buildPlace(modulesXml, bootstrap);
const modelXml = buildModel(modulesXml, bootstrap);
writeFileSync(OUT_PLACE, placeXml, "utf8");
writeFileSync(OUT_MODEL, modelXml, "utf8");
writeFileSync(OUT_PLACE_UPDATED, placeXml, "utf8");
writeFileSync(OUT_MODEL_UPDATED, modelXml, "utf8");
writeFileSync(OUT_PLACE_LATEST, placeXml, "utf8");
writeFileSync(OUT_MODEL_LATEST, modelXml, "utf8");
console.log(`Wrote ${OUT_PLACE}`);
console.log(`Wrote ${OUT_MODEL}`);
console.log(`Wrote ${OUT_PLACE_UPDATED}`);
console.log(`Wrote ${OUT_MODEL_UPDATED}`);
console.log(`Wrote ${OUT_PLACE_LATEST}`);
console.log(`Wrote ${OUT_MODEL_LATEST}`);
