--[[
	SoftPhoneUI bootstrap.
	Drop under StarterGui/SoftPhoneUI as a LocalScript.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local Workspace = game:GetService("Workspace")

local BACK_ACTION = "SoftPhoneBack"

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

local windowHost = Instance.new("Frame")
windowHost.Name = "WindowHost"
windowHost.BackgroundTransparency = 1
windowHost.Size = UDim2.fromScale(1, 1)
windowHost.ZIndex = 250
windowHost.Parent = screenGui

local sidebar
local manager
local notifications
local oldActionEvent = screenGui:FindFirstChild("SoftPhoneAction")
if oldActionEvent then
	oldActionEvent:Destroy()
end
local oldBridge = screenGui:FindFirstChild("SoftPhoneWindowManager")
if oldBridge then
	oldBridge:Destroy()
end
local actionEvent = Instance.new("BindableEvent")
actionEvent.Name = "SoftPhoneAction"
actionEvent.Parent = screenGui

local ok, initError = pcall(function()
	local modules = ReplicatedStorage:WaitForChild("SoftPhoneModules", 10)
	assert(modules, "ReplicatedStorage.SoftPhoneModules was not found")
	local sidebarModule = modules:WaitForChild("Sidebar", 10)
	assert(sidebarModule, "SoftPhoneModules.Sidebar was not found")
	local Sidebar = require(sidebarModule)
	local windowManagerModule = modules:WaitForChild("WindowManager", 10)
	assert(windowManagerModule, "SoftPhoneModules.WindowManager was not found")
	local WindowManager = require(windowManagerModule)
	local notificationModule = modules:WaitForChild("NotificationCenter", 10)
	assert(notificationModule, "SoftPhoneModules.NotificationCenter was not found")
	local NotificationCenter = require(notificationModule)
	notifications = NotificationCenter.new(screenGui)

	manager = WindowManager.new(windowHost, function(activeId: string?)
		if sidebar then
			sidebar:setActive(activeId)
			if activeId == "Gacha" and sidebar:isExpanded() then
				sidebar:setExpanded(false, false)
			end
		end
	end, function(eventName: string, value)
		if sidebar and eventName == "MessagesUnread" then
			sidebar:setBadge("Messages", tostring(value))
		end
	end, function(appId: string, actionName: string, payload)
		notifications:show(appId, actionName, payload)
		actionEvent:Fire(appId, actionName, payload)
	end)

	sidebar = Sidebar.new(screenGui, function(id: string)
		manager:open(id)
	end)

	local bridge = Instance.new("BindableFunction")
	bridge.Name = "SoftPhoneWindowManager"
	bridge.OnInvoke = function(commandOrId: string, targetOrValue, value)
		local id = typeof(targetOrValue) == "string" and targetOrValue or nil
		if commandOrId == "Open" then
			return manager:show(id)
		elseif commandOrId == "Close" then
			return manager:hide(id)
		elseif commandOrId == "Toggle" then
			return manager:open(id)
		elseif commandOrId == "CloseAll" then
			manager:closeAll(false)
			return nil
		elseif commandOrId == "GetActive" then
			return manager:getActive()
		elseif commandOrId == "IsAvailable" then
			return manager:isAvailable(id)
		elseif commandOrId == "IsPhoneExpanded" then
			return sidebar:isExpanded()
		elseif commandOrId == "SetPhoneExpanded" then
			local expanded = typeof(targetOrValue) == "boolean" and targetOrValue or value == true
			sidebar:setExpanded(expanded, false)
			return sidebar:isExpanded()
		elseif commandOrId == "TogglePhone" then
			sidebar:toggle()
			return sidebar:isExpanded()
		end
		return manager:open(commandOrId)
	end
	bridge.Parent = screenGui

	ContextActionService:BindAction(BACK_ACTION, function(_, inputState)
		if inputState ~= Enum.UserInputState.Begin then
			return Enum.ContextActionResult.Pass
		end
		if manager:getActive() then
			manager:closeAll(false)
			return Enum.ContextActionResult.Sink
		end
		if sidebar:isExpanded() then
			sidebar:setExpanded(false, false)
			return Enum.ContextActionResult.Sink
		end
		return Enum.ContextActionResult.Pass
	end, false, Enum.KeyCode.ButtonB, Enum.KeyCode.Escape)
end)

if ok then
	screenGui.Destroying:Connect(function()
		ContextActionService:UnbindAction(BACK_ACTION)
	end)
	if staticLauncher then
		staticLauncher:Destroy()
		staticLauncher = nil
	end
	print("[SoftPhoneUI] Ready - click the gem on the edge tab to open Furu Phone.")
else
	ContextActionService:UnbindAction(BACK_ACTION)
	windowHost:Destroy()
	actionEvent:Destroy()
	if notifications and notifications.Root then
		notifications.Root:Destroy()
	end
	local errorLabel = staticLauncher :: GuiButton
	errorLabel.Name = "SoftPhoneError"
	errorLabel.Text = "UI ERROR\nCHECK OUTPUT"
	errorLabel.ZIndex = 999
	warn("[SoftPhoneUI] Initialization failed:", initError)
end
