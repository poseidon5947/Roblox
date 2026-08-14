--[[
	Flip-phone sidebar.
	The edge tab is fixed; the phone panel slides in behind it.
]]

local Theme = require(script.Parent.Theme)
local TweenUtil = require(script.Parent.TweenUtil)
local IconDraw = require(script.Parent.IconDraw)
local Workspace = game:GetService("Workspace")

local Sidebar = {}
Sidebar.__index = Sidebar

local function clampWidth(absX: number): number
	local w = math.floor(absX * Theme.Sizes.SidebarWidthScale)
	return math.clamp(w, Theme.Sizes.SidebarWidthMin, Theme.Sizes.SidebarWidthMax)
end

local function clampHeight(absY: number): number
	local h = math.floor(absY * Theme.Sizes.SidebarHeightScale)
	local maxHeight = math.max(260, absY - 16)
	local minHeight = math.min(430, maxHeight)
	return math.clamp(h, minHeight, maxHeight)
end

local function isRightSide(): boolean
	return Theme.Side == "Right"
end

local function viewportSize(): Vector2
	local camera = Workspace.CurrentCamera
	if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
		return camera.ViewportSize
	end
	return Vector2.new(1280, 720)
end

local function addStroke(parent: Instance, color: Color3, thickness: number, transparency: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
	return stroke
end

local function addCorner(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function addSparkle(parent: Instance, position: UDim2, size: number, zIndex: number)
	local sparkle = Instance.new("Frame")
	sparkle.Name = "Sparkle"
	sparkle.BackgroundTransparency = 1
	sparkle.Position = position
	sparkle.Size = UDim2.fromOffset(size, size)
	sparkle.ZIndex = zIndex
	sparkle.Parent = parent

	local vertical = Instance.new("Frame")
	vertical.Name = "Vertical"
	vertical.AnchorPoint = Vector2.new(0.5, 0.5)
	vertical.Position = UDim2.fromScale(0.5, 0.5)
	vertical.Size = UDim2.new(0, math.max(2, math.floor(size * 0.18)), 1, 0)
	vertical.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	vertical.BorderSizePixel = 0
	vertical.ZIndex = zIndex + 1
	vertical.Parent = sparkle
	addCorner(vertical, size)

	local horizontal = vertical:Clone()
	horizontal.Name = "Horizontal"
	horizontal.Size = UDim2.new(1, 0, 0, math.max(2, math.floor(size * 0.18)))
	horizontal.Parent = sparkle

	return sparkle
end

local function decorationImage(name: string): string?
	local images = Theme.DecorationImages
	local image = images and images[name]
	if typeof(image) == "string" and image ~= "" then
		return image
	end
	return nil
end

local function addImageDecoration(parent: Instance, name: string, imageName: string, position: UDim2, size: UDim2, zIndex: number): ImageLabel?
	local image = decorationImage(imageName)
	if not image then
		return nil
	end

	local item = Instance.new("ImageLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.Image = image
	item.ScaleType = Enum.ScaleType.Fit
	item.Position = position
	item.Size = size
	item.ZIndex = zIndex
	item.Parent = parent
	return item
end

local function addBow(parent: Instance, position: UDim2, zIndex: number, imageName: string?)
	local image = addImageDecoration(parent, "BowDecoration", imageName or "bowHeart", position, UDim2.fromOffset(58, 48), zIndex + 4)
	if image then
		return image
	end

	local bow = Instance.new("Frame")
	bow.Name = "BowDecoration"
	bow.BackgroundTransparency = 1
	bow.Position = position
	bow.Size = UDim2.fromOffset(54, 38)
	bow.ZIndex = zIndex
	bow.Parent = parent

	local left = Instance.new("Frame")
	left.Name = "LeftWing"
	left.BackgroundColor3 = Theme.Colors.AccentPink
	left.BorderSizePixel = 0
	left.Position = UDim2.fromOffset(2, 6)
	left.Size = UDim2.fromOffset(23, 18)
	left.Rotation = 18
	left.ZIndex = zIndex + 1
	left.Parent = bow
	addCorner(left, 8)
	addStroke(left, Color3.fromRGB(255, 255, 255), 1.25, 0.08)

	local right = left:Clone()
	right.Name = "RightWing"
	right.Position = UDim2.fromOffset(29, 6)
	right.Rotation = -18
	right.Parent = bow

	local leftTail = Instance.new("Frame")
	leftTail.Name = "LeftTail"
	leftTail.BackgroundColor3 = Color3.fromRGB(255, 202, 229)
	leftTail.BorderSizePixel = 0
	leftTail.Position = UDim2.fromOffset(13, 20)
	leftTail.Size = UDim2.fromOffset(11, 17)
	leftTail.Rotation = 23
	leftTail.ZIndex = zIndex + 1
	leftTail.Parent = bow
	addCorner(leftTail, 4)
	addStroke(leftTail, Color3.fromRGB(255, 255, 255), 1, 0.16)

	local rightTail = leftTail:Clone()
	rightTail.Name = "RightTail"
	rightTail.Position = UDim2.fromOffset(31, 20)
	rightTail.Rotation = -23
	rightTail.Parent = bow

	local knot = Instance.new("Frame")
	knot.Name = "GemKnot"
	knot.BackgroundColor3 = Theme.Colors.Gem
	knot.BorderSizePixel = 0
	knot.Position = UDim2.fromOffset(22, 8)
	knot.Size = UDim2.fromOffset(12, 12)
	knot.Rotation = 45
	knot.ZIndex = zIndex + 2
	knot.Parent = bow
	addCorner(knot, 3)
	addStroke(knot, Color3.fromRGB(255, 255, 255), 1.2, 0.03)

	for i, data in ipairs({
		{ 18, 5 },
		{ 27, 3 },
		{ 36, 5 },
	}) do
		local pearl = Instance.new("Frame")
		pearl.Name = "Pearl" .. i
		pearl.BackgroundColor3 = Color3.fromRGB(255, 245, 252)
		pearl.BorderSizePixel = 0
		pearl.Position = UDim2.fromOffset(data[1], data[2])
		pearl.Size = UDim2.fromOffset(5, 5)
		pearl.ZIndex = zIndex + 3
		pearl.Parent = bow
		addCorner(pearl, 999)
	end

	addSparkle(bow, UDim2.fromOffset(8, 3), 8, zIndex + 4)
	addSparkle(bow, UDim2.fromOffset(42, 17), 6, zIndex + 4)

	return bow
end

local function addGem(parent: Instance, position: UDim2, size: number, zIndex: number, imageName: string?)
	local image = addImageDecoration(parent, "GemDecoration", imageName or "gemDiamond", position, UDim2.fromOffset(size + 12, size + 14), zIndex + 2)
	if image then
		return image
	end

	local gemHost = Instance.new("Frame")
	gemHost.Name = "GemDecoration"
	gemHost.BackgroundTransparency = 1
	gemHost.Position = position
	gemHost.Size = UDim2.fromOffset(size + 8, size + 8)
	gemHost.ZIndex = zIndex
	gemHost.Parent = parent
	IconDraw.makeGem(gemHost, size)
	return gemHost
end

function Sidebar.new(screenGui: ScreenGui, onButtonClick: (string) -> ())
	local self = setmetatable({}, Sidebar)
	self._gui = screenGui
	self._expanded = false
	self._tweening = false
	self._onButtonClick = onButtonClick
	local vp = viewportSize()
	self._width = clampWidth(vp.X)
	self._height = clampHeight(vp.Y)

	self:_build()
	self:_bindResize()
	self:setExpanded(false, true)

	return self
end

function Sidebar:_build()
	local root = Instance.new("Frame")
	root.Name = "SidebarRoot"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Position = UDim2.fromScale(0, 0)
	root.ZIndex = 200
	root.Parent = self._gui
	self.Root = root

	local panel = Instance.new("Frame")
	panel.Name = "PhonePanel"
	panel.AnchorPoint = Vector2.new(isRightSide() and 1 or 0, 0.5)
	panel.BackgroundColor3 = Theme.Colors.PanelFill
	panel.BorderSizePixel = 0
	panel.Size = UDim2.fromOffset(self._width, self._height)
	panel.Position = self:_collapsedPos()
	panel.ZIndex = 201
	panel.ClipsDescendants = true
	panel.Parent = root
	self.Panel = panel

	local panelCorner = Instance.new("UICorner")
	panelCorner.CornerRadius = UDim.new(0, Theme.Sizes.CornerRadius)
	panelCorner.Parent = panel

	local panelStroke = Instance.new("UIStroke")
	panelStroke.Color = Theme.Colors.AccentPink
	panelStroke.Thickness = 2.5
	panelStroke.Transparency = 0.05
	panelStroke.Parent = panel

	local tab = Instance.new("Frame")
	tab.Name = "OuterTab"
	tab.AnchorPoint = Vector2.new(isRightSide() and 1 or 0, 0.5)
	tab.BackgroundColor3 = Theme.Colors.AccentPink
	tab.BorderSizePixel = 0
	tab.Size = UDim2.fromOffset(Theme.Sizes.TabReveal + 8, self._height)
	tab.Position = isRightSide() and UDim2.new(1, -6, 0.5, 0) or UDim2.new(0, 6, 0.5, 0)
	tab.ZIndex = 230
	tab.Parent = root
	self.Tab = tab

	local tabCorner = Instance.new("UICorner")
	tabCorner.CornerRadius = UDim.new(0, 14)
	tabCorner.Parent = tab

	local tabStroke = Instance.new("UIStroke")
	tabStroke.Color = Color3.fromRGB(255, 255, 255)
	tabStroke.Thickness = 2
	tabStroke.Transparency = 0.05
	tabStroke.Parent = tab

	for i = 1, 5 do
		local dot = Instance.new("Frame")
		dot.Name = "Filigree" .. i
		dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		dot.BorderSizePixel = 0
		dot.Size = UDim2.fromOffset(6, 6)
		dot.AnchorPoint = Vector2.new(0.5, 0)
		dot.Position = UDim2.new(0.5, 0, 0, 18 + (i - 1) * 22)
		dot.ZIndex = 231
		dot.Parent = tab
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(1, 0)
		c.Parent = dot
	end

	local gemHit = Instance.new("TextButton")
	gemHit.Name = "GemToggle"
	gemHit.Text = ""
	gemHit.AutoButtonColor = false
	gemHit.BackgroundTransparency = 1
	gemHit.Size = UDim2.fromOffset(Theme.Sizes.GemSize + 12, Theme.Sizes.GemSize + 12)
	gemHit.AnchorPoint = Vector2.new(0.5, 0.5)
	gemHit.Position = UDim2.new(0.5, 0, 0.5, 0)
	gemHit.ZIndex = 240
	gemHit.Parent = tab
	self.GemButton = gemHit

	if not addImageDecoration(gemHit, "GemArt", "gemDiamond", UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), 241) then
		IconDraw.makeGem(gemHit, Theme.Sizes.GemSize)
	end

	local header = Instance.new("Frame")
	header.Name = "Header"
	header.BackgroundTransparency = 1
	header.Size = UDim2.new(1, -16, 0, 66)
	header.Position = UDim2.fromOffset(8, 8)
	header.ZIndex = 202
	header.Parent = panel

	local badge = Instance.new("Frame")
	badge.Name = "PhoneBadge"
	badge.BackgroundColor3 = Theme.Colors.ButtonFill
	badge.BorderSizePixel = 0
	badge.AnchorPoint = Vector2.new(0.5, 0)
	badge.Position = UDim2.new(0.5, 0, 0, 0)
	badge.Size = UDim2.fromOffset(62, 36)
	badge.ZIndex = 203
	badge.Parent = header

	local badgeCorner = Instance.new("UICorner")
	badgeCorner.CornerRadius = UDim.new(0, 14)
	badgeCorner.Parent = badge

	local screen = Instance.new("Frame")
	screen.Name = "MiniScreen"
	screen.BackgroundColor3 = Theme.Colors.AccentCream
	screen.BorderSizePixel = 0
	screen.AnchorPoint = Vector2.new(0.5, 0.5)
	screen.Position = UDim2.fromScale(0.5, 0.55)
	screen.Size = UDim2.new(0.56, 0, 0.34, 0)
	screen.ZIndex = 204
	screen.Parent = badge

	local screenCorner = Instance.new("UICorner")
	screenCorner.CornerRadius = UDim.new(0, 4)
	screenCorner.Parent = screen

	local titlePill = Instance.new("TextLabel")
	titlePill.Name = "TitlePill"
	titlePill.BackgroundColor3 = Theme.Colors.ButtonFill
	titlePill.BorderSizePixel = 0
	titlePill.AnchorPoint = Vector2.new(0.5, 0)
	titlePill.Position = UDim2.new(0.5, 0, 0, 42)
	titlePill.Size = UDim2.new(0.84, 0, 0, 22)
	titlePill.Font = Theme.Fonts.Title
	titlePill.TextSize = 12
	titlePill.TextColor3 = Theme.Colors.AccentPinkDeep
	titlePill.Text = "FURU PHONE"
	titlePill.ZIndex = 203
	titlePill.Parent = header

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(1, 0)
	titleCorner.Parent = titlePill

	addBow(header, UDim2.new(0, -2, 0, -2), 205, "bowHeart")
	addBow(header, UDim2.new(1, -58, 0, -2), 205, "bowHeart")
	addBow(panel, UDim2.new(0, 4, 1, -54), 205, "bowOval")
	addBow(panel, UDim2.new(1, -64, 0, 68), 205, "bowHeart")

	for i, decoration in ipairs({
		{ UDim2.new(0, 16, 1, -68), 16, UDim2.new(0, 34, 1, -72) },
		{ UDim2.new(1, -30, 1, -92), 12, UDim2.new(1, -14, 1, -96) },
		{ UDim2.new(0, 22, 0, 78), 13 },
		{ UDim2.new(1, -36, 0, 116), 10 },
	}) do
		addGem(panel, decoration[1], decoration[2], 204, i % 2 == 0 and "gemHeart" or "gemDiamond")
		if decoration[3] then
			addSparkle(panel, decoration[3], 7, 206)
		end
	end

	local currency = Instance.new("Frame")
	currency.Name = "CurrencyBubble"
	currency.BackgroundColor3 = Theme.Colors.AccentCream
	currency.BorderSizePixel = 0
	currency.Size = UDim2.new(0.88, 0, 0, 32)
	currency.Position = UDim2.new(0.06, 0, 0, 80)
	currency.ZIndex = 202
	currency.Parent = panel

	local curCorner = Instance.new("UICorner")
	curCorner.CornerRadius = UDim.new(1, 0)
	curCorner.Parent = currency

	local curStroke = Instance.new("UIStroke")
	curStroke.Color = Theme.Colors.AccentPink
	curStroke.Thickness = 1.5
	curStroke.Transparency = 0.2
	curStroke.Parent = currency

	local curLabel = Instance.new("TextLabel")
	curLabel.Name = "Amount"
	curLabel.BackgroundTransparency = 1
	curLabel.Size = UDim2.fromScale(1, 1)
	curLabel.Font = Theme.Fonts.Title
	curLabel.TextSize = 14
	curLabel.TextColor3 = Theme.Colors.AccentPinkDeep
	curLabel.Text = "GEMS  12,217"
	curLabel.ZIndex = 203
	curLabel.Parent = currency

	local list = Instance.new("ScrollingFrame")
	list.Name = "ButtonList"
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.Size = UDim2.new(1, -20, 1, -166)
	list.Position = UDim2.fromOffset(10, 120)
	list.CanvasSize = UDim2.fromOffset(0, 0)
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.ScrollBarThickness = 0
	list.ScrollingDirection = Enum.ScrollingDirection.Y
	list.ClipsDescendants = true
	list.ZIndex = 202
	list.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Padding = UDim.new(0, 6)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = list

	self.Buttons = {}
	for i, def in ipairs(Theme.Buttons) do
		local btn = Instance.new("TextButton")
		btn.Name = def.Id .. "Button"
		btn.AutoButtonColor = false
		btn.BackgroundColor3 = Theme.Colors.ButtonFill
		btn.BorderSizePixel = 0
		btn.Size = UDim2.new(1, 0, 0, Theme.Sizes.ButtonHeight)
		btn.LayoutOrder = i
		btn.Text = ""
		btn.ZIndex = 203
		btn.Parent = list

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(1, 0)
		btnCorner.Parent = btn

		local btnStroke = Instance.new("UIStroke")
		btnStroke.Color = Theme.Colors.ButtonStroke
		btnStroke.Thickness = 1
		btnStroke.Transparency = 0.35
		btnStroke.Parent = btn

		IconDraw.makeCircleIcon(btn, def.Icon, Theme.Colors.AccentCream)

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Position = UDim2.fromOffset(48, 0)
		label.Size = UDim2.new(1, -56, 1, 0)
		label.Font = Theme.Fonts.Title
		label.TextSize = 16
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextColor3 = Theme.Colors.AccentPinkDeep
		label.Text = def.Label
		label.ZIndex = 205
		label.Parent = btn

		btn.MouseEnter:Connect(function()
			TweenUtil.play(btn, { BackgroundColor3 = Theme.Colors.ButtonFillHover }, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
		end)

		btn.MouseLeave:Connect(function()
			TweenUtil.play(btn, { BackgroundColor3 = Theme.Colors.ButtonFill }, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
		end)

		btn.Activated:Connect(function()
			if not self._expanded then
				self:setExpanded(true, false)
			end
			if self._onButtonClick then
				self._onButtonClick(def.Id)
			end
		end)

		self.Buttons[def.Id] = btn
	end

	local level = Instance.new("Frame")
	level.Name = "LevelBubble"
	level.BackgroundColor3 = Theme.Colors.AccentCream
	level.BorderSizePixel = 0
	level.AnchorPoint = Vector2.new(0.5, 1)
	level.Position = UDim2.new(0.5, 0, 1, -10)
	level.Size = UDim2.new(0.88, 0, 0, 30)
	level.ZIndex = 202
	level.Parent = panel

	local lvCorner = Instance.new("UICorner")
	lvCorner.CornerRadius = UDim.new(1, 0)
	lvCorner.Parent = level

	local lvStroke = Instance.new("UIStroke")
	lvStroke.Color = Theme.Colors.AccentLavender
	lvStroke.Thickness = 1.5
	lvStroke.Transparency = 0.2
	lvStroke.Parent = level

	local lvLabel = Instance.new("TextLabel")
	lvLabel.BackgroundTransparency = 1
	lvLabel.Size = UDim2.fromScale(1, 1)
	lvLabel.Font = Theme.Fonts.Body
	lvLabel.TextSize = 14
	lvLabel.TextColor3 = Theme.Colors.TextPrimary
	lvLabel.Text = "LEVEL 1"
	lvLabel.ZIndex = 203
	lvLabel.Parent = level

	gemHit.Activated:Connect(function()
		self:toggle()
	end)
end

function Sidebar:_collapsedPos(): UDim2
	if isRightSide() then
		return UDim2.new(1, self._width + Theme.Sizes.TabReveal, 0.5, 0)
	end
	return UDim2.new(0, -self._width - Theme.Sizes.TabReveal, 0.5, 0)
end

function Sidebar:_expandedPos(): UDim2
	if isRightSide() then
		return UDim2.new(1, -Theme.Sizes.TabReveal - 10, 0.5, 0)
	end
	return UDim2.new(0, Theme.Sizes.TabReveal + 10, 0.5, 0)
end

function Sidebar:setExpanded(expanded: boolean, instant: boolean?)
	self._expanded = expanded
	local target = expanded and self:_expandedPos() or self:_collapsedPos()
	local closedRotation = isRightSide() and 4 or -4

	if instant then
		self.Panel.Position = target
		self.Panel.Rotation = expanded and 0 or closedRotation
		self._tweening = false
		return
	end

	self._tweening = true
	local tw = TweenUtil.play(self.Panel, {
		Position = target,
		Rotation = expanded and 0 or closedRotation,
	}, Theme.Tween.SlideTime, Theme.Tween.SlideStyle, Theme.Tween.SlideDir)
	tw.Completed:Connect(function()
		self._tweening = false
	end)
end

function Sidebar:toggle()
	if self._tweening then
		return
	end
	self:setExpanded(not self._expanded, false)
end

function Sidebar:isExpanded(): boolean
	return self._expanded
end

function Sidebar:_bindResize()
	local function resize()
		local vp = viewportSize()
		self._width = clampWidth(vp.X)
		self._height = clampHeight(vp.Y)
		self.Root.Size = UDim2.fromScale(1, 1)
		self.Panel.AnchorPoint = Vector2.new(isRightSide() and 1 or 0, 0.5)
		self.Panel.Size = UDim2.fromOffset(self._width, self._height)
		self.Panel.Position = self._expanded and self:_expandedPos() or self:_collapsedPos()
		self.Tab.AnchorPoint = Vector2.new(isRightSide() and 1 or 0, 0.5)
		self.Tab.Size = UDim2.fromOffset(Theme.Sizes.TabReveal + 8, self._height)
		self.Tab.Position = isRightSide() and UDim2.new(1, -6, 0.5, 0) or UDim2.new(0, 6, 0.5, 0)
	end

	local function bindCamera(camera: Camera?)
		if camera then
			camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
		end
	end

	bindCamera(Workspace.CurrentCamera)
	Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		bindCamera(Workspace.CurrentCamera)
		resize()
	end)
end

return Sidebar

