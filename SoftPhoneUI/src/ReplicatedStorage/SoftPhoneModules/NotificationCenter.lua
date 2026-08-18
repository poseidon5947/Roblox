--[[
	Compact global feedback for app commands.
	New messages replace the current toast so repeated clicks never stack or overlap.
]]

local Theme = require(script.Parent.Theme)
local TweenUtil = require(script.Parent.TweenUtil)
local IconDraw = require(script.Parent.IconDraw)

local NotificationCenter = {}
NotificationCenter.__index = NotificationCenter

local APP_ICONS = {
	Shop = "bag",
	Gacha = "star",
	Map = "map",
	Messages = "mail",
	Teleport = "portal",
	Job = "briefcase",
}

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
	return item
end

local function humanize(value: any): string
	local text = tostring(value or "")
	text = text:gsub("_", " "):gsub("(%l)(%u)", "%1 %2")
	return text:gsub("^%l", string.upper)
end

local function feedbackText(appId: string, actionName: string, payload): (string, string)
	payload = typeof(payload) == "table" and payload or {}
	if actionName == "SelectItem" then
		return "Item selected", humanize(payload.ItemKey)
	elseif actionName == "ResetLook" then
		return "Look reset", "Your preview avatar is back to default."
	elseif actionName == "RotatePreview" then
		return "Preview rotated", tostring(math.floor(tonumber(payload.Angle) or 0)) .. " degrees"
	elseif actionName == "ApplyPreview" then
		return "Preview applied", humanize(payload.ItemKey)
	end

	local result = payload.Result and humanize(payload.Result) or "Complete"
	return humanize(appId), humanize(actionName) .. "  |  " .. result
end

function NotificationCenter.new(parent: Instance)
	local self = setmetatable({}, NotificationCenter)
	self._serial = 0
	self._activeTween = nil
	local existing = parent:FindFirstChild("ActionToast")
	if existing then
		existing:Destroy()
	end

	local toast = Instance.new("Frame")
	toast.Name = "ActionToast"
	toast.AnchorPoint = Vector2.new(0.5, 0)
	toast.Position = UDim2.new(0.5, 0, 0, -80)
	toast.Size = UDim2.new(0.88, 0, 0, 66)
	toast.BackgroundColor3 = Color3.fromRGB(255, 247, 252)
	toast.BackgroundTransparency = 0
	toast.BorderSizePixel = 0
	toast.ClipsDescendants = true
	toast.Visible = false
	toast.ZIndex = 950
	toast.Parent = parent
	corner(toast, 8)

	local constraint = Instance.new("UISizeConstraint")
	constraint.MinSize = Vector2.new(260, 66)
	constraint.MaxSize = Vector2.new(390, 66)
	constraint.Parent = toast

	local outline = Instance.new("UIStroke")
	outline.Color = Theme.Colors.ButtonStroke
	outline.Thickness = 1.5
	outline.Transparency = 0.08
	outline.Parent = toast

	local accent = Instance.new("Frame")
	accent.Name = "PinkTab"
	accent.BackgroundColor3 = Theme.Colors.AccentPink
	accent.BorderSizePixel = 0
	accent.Size = UDim2.fromOffset(5, 66)
	accent.ZIndex = 951
	accent.Parent = toast

	local icon = IconDraw.makeCircleIcon(toast, "gem", Theme.Colors.AccentCream)
	icon.Name = "AppIcon"
	icon.Position = UDim2.new(0, 14, 0.5, 0)
	icon.Size = UDim2.fromOffset(38, 38)
	icon.ZIndex = 952
	self.Icon = icon

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.fromOffset(64, 11)
	title.Size = UDim2.new(1, -104, 0, 20)
	title.Font = Theme.Fonts.Title
	title.Text = "Updated"
	title.TextColor3 = Theme.Colors.TextPrimary
	title.TextSize = 13
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.ZIndex = 952
	title.Parent = toast

	local detail = Instance.new("TextLabel")
	detail.Name = "Detail"
	detail.BackgroundTransparency = 1
	detail.Position = UDim2.fromOffset(64, 32)
	detail.Size = UDim2.new(1, -104, 0, 20)
	detail.Font = Theme.Fonts.Body
	detail.Text = "Action complete"
	detail.TextColor3 = Theme.Colors.TextMuted
	detail.TextSize = 10
	detail.TextTruncate = Enum.TextTruncate.AtEnd
	detail.TextXAlignment = Enum.TextXAlignment.Left
	detail.ZIndex = 952
	detail.Parent = toast

	local gem = Instance.new("Frame")
	gem.Name = "Gem"
	gem.AnchorPoint = Vector2.new(0.5, 0.5)
	gem.Position = UDim2.new(1, -20, 0.5, 0)
	gem.Size = UDim2.fromOffset(13, 13)
	gem.BackgroundColor3 = Theme.Colors.Gem
	gem.BorderSizePixel = 0
	gem.Rotation = 45
	gem.ZIndex = 953
	gem.Parent = toast
	corner(gem, 3)

	self.Root = toast
	self.Title = title
	self.Detail = detail
	return self
end

function NotificationCenter:show(appId: string, actionName: string, payload)
	self._serial += 1
	local serial = self._serial
	if self._activeTween then
		self._activeTween:Cancel()
		self._activeTween = nil
	end

	local title, detail = feedbackText(appId, actionName, payload)
	self.Title.Text = title
	self.Detail.Text = detail

	local iconName = APP_ICONS[appId] or "gem"
	self.Icon:Destroy()
	self.Icon = IconDraw.makeCircleIcon(self.Root, iconName, Theme.Colors.AccentCream)
	self.Icon.Name = "AppIcon"
	self.Icon.Position = UDim2.new(0, 14, 0.5, 0)
	self.Icon.Size = UDim2.fromOffset(38, 38)
	self.Icon.ZIndex = 952

	self.Root.Visible = true
	self.Root.Position = UDim2.new(0.5, 0, 0, -80)
	self.Root.BackgroundTransparency = 0
	self._activeTween = TweenUtil.play(self.Root, {
		Position = UDim2.new(0.5, 0, 0, 72),
	}, Theme.Tween.QuickTime, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	task.delay(2.2, function()
		if serial ~= self._serial or not self.Root.Parent then
			return
		end
		local tween = TweenUtil.play(self.Root, {
			Position = UDim2.new(0.5, 0, 0, -80),
		}, Theme.Tween.QuickTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		self._activeTween = tween
		tween.Completed:Connect(function()
			if serial == self._serial and self.Root.Parent then
				self.Root.Visible = false
				self._activeTween = nil
			end
		end)
	end)
end

return NotificationCenter
