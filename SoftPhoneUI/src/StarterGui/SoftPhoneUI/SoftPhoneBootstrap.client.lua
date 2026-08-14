--[[
	SoftPhoneUI bootstrap.
	Drop under StarterGui/SoftPhoneUI as a LocalScript.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local screenGui = script.Parent
if not screenGui:IsA("ScreenGui") then
	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SoftPhoneUI"
	screenGui.Parent = playerGui
	script.Parent = screenGui
end

screenGui.Name = "SoftPhoneUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 100
screenGui.Enabled = true

-- The exported files include this launcher so the edge control is visible even
-- before modules load. Keep it until the complete sidebar has been constructed.
local staticLauncher = screenGui:FindFirstChild("StaticEdgeLauncher")

local function makeRuntimeLauncher(): TextButton
	local launcher = Instance.new("TextButton")
	launcher.Name = "StaticEdgeLauncher"
	launcher.AnchorPoint = Vector2.new(1, 0.5)
	launcher.Position = UDim2.new(1, -6, 0.5, 0)
	launcher.Size = UDim2.fromOffset(42, 240)
	launcher.BackgroundColor3 = Color3.fromRGB(255, 211, 233)
	launcher.BorderSizePixel = 0
	launcher.AutoButtonColor = false
	launcher.Font = Enum.Font.GothamBold
	launcher.Text = "FURU\nPHONE"
	launcher.TextColor3 = Color3.fromRGB(232, 95, 166)
	launcher.TextSize = 11
	launcher.TextWrapped = true
	launcher.ZIndex = 900
	launcher.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = launcher

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Thickness = 2
	stroke.Parent = launcher

	return launcher
end

if not staticLauncher or not staticLauncher:IsA("GuiButton") then
	if staticLauncher then
		staticLauncher:Destroy()
	end
	staticLauncher = makeRuntimeLauncher()
end

for _ = 1, 120 do
	local camera = Workspace.CurrentCamera
	if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
		break
	end
	task.wait()
end

local sidebar
local okSidebar, sidebarOrError = pcall(function()
	local modules = ReplicatedStorage:WaitForChild("SoftPhoneModules", 10)
	assert(modules, "ReplicatedStorage.SoftPhoneModules was not found")
	local sidebarModule = modules:WaitForChild("Sidebar", 10)
	assert(sidebarModule, "SoftPhoneModules.Sidebar was not found")
	local Sidebar = require(sidebarModule)
	return Sidebar.new(screenGui, function(id: string)
		if sidebar and not sidebar:isExpanded() then
			sidebar:setExpanded(true, false)
		end
		local windows = screenGui:FindFirstChild("SoftPhoneWindowManager")
		if windows and windows:IsA("BindableFunction") then
			windows:Invoke(id)
		else
			warn("[SoftPhoneUI] Window manager is not ready yet:", id)
		end
	end)
end)

if okSidebar then
	sidebar = sidebarOrError
	if staticLauncher then
		staticLauncher:Destroy()
		staticLauncher = nil
	end
else
	local errorLabel = staticLauncher :: GuiButton
	errorLabel.Name = "SoftPhoneError"
	errorLabel.Text = "UI ERROR\nCHECK OUTPUT"
	errorLabel.ZIndex = 999
	warn("[SoftPhoneUI] Sidebar failed:", sidebarOrError)
end

local windowHost = Instance.new("Frame")
windowHost.Name = "WindowHost"
windowHost.BackgroundTransparency = 1
windowHost.Size = UDim2.fromScale(1, 1)
windowHost.ZIndex = 250
windowHost.Parent = screenGui

task.spawn(function()
	local ok, err = pcall(function()
		local modules = ReplicatedStorage:WaitForChild("SoftPhoneModules", 10)
		assert(modules, "ReplicatedStorage.SoftPhoneModules was not found")
		local WindowManager = require(modules:WaitForChild("WindowManager"))
		local manager = WindowManager.new(windowHost)
		local bridge = Instance.new("BindableFunction")
		bridge.Name = "SoftPhoneWindowManager"
		bridge.OnInvoke = function(id: string)
			manager:open(id)
		end
		bridge.Parent = screenGui
	end)
	if not ok then
		warn("[SoftPhoneUI] Window manager failed:", err)
	end
end)

print("[SoftPhoneUI] Ready - click the gem on the edge tab to open Furu Phone.")
