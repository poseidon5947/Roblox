--[[
	Shared futuristic .exe window chrome.
	Windows are draggable, minimizable, maximizable, and use the same slide motion.
]]

local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Theme = require(script.Parent.Theme)
local TweenUtil = require(script.Parent.TweenUtil)
local IconDraw = require(script.Parent.IconDraw)

local WindowChrome = {}

local WINDOW_ICONS = {
	Shop = "bag",
	Gacha = "star",
	Map = "map",
	Messages = "mail",
	Teleport = "portal",
	Job = "briefcase",
}

export type WindowHandle = {
	Root: Frame,
	Content: Frame,
	Footer: Frame,
	TitleLabel: TextLabel,
	setVisible: (self: WindowHandle, visible: boolean, instant: boolean?) -> (),
	isOpen: (self: WindowHandle) -> boolean,
}

local function viewportWidth(): number
	local camera = Workspace.CurrentCamera
	return camera and camera.ViewportSize.X or 1280
end

local function openPosition(fullScreen: boolean?): UDim2
	if fullScreen or viewportWidth() < 720 then
		return UDim2.fromScale(0.5, 0.5)
	end
	return UDim2.fromScale(Theme.Side == "Right" and 0.39 or 0.61, 0.5)
end

local function closedPosition(): UDim2
	if Theme.Side == "Right" then
		return UDim2.fromScale(1.2, 0.5)
	end
	return UDim2.fromScale(-0.22, 0.5)
end

local function addCorner(parent: Instance, radius: number)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = parent
	return corner
end

local function addStroke(parent: Instance, color: Color3, thickness: number, transparency: number?)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = thickness
	stroke.Transparency = transparency or 0
	stroke.Parent = parent
	return stroke
end

local function addGradient(parent: Instance, colors: { Color3 }, rotation: number?)
	local points = {}
	for i, color in ipairs(colors) do
		table.insert(points, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color))
	end
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new(points)
	gradient.Rotation = rotation or 0
	gradient.Parent = parent
	return gradient
end

local function makeText(parent: Instance, name: string, text: string, font: Enum.Font, size: number, color: Color3, z: number)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.BackgroundTransparency = 1
	label.Font = font
	label.Text = text
	label.TextSize = size
	label.TextColor3 = color
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = z
	label.Parent = parent
	return label
end

local function addUploadedIcon(parent: Instance, iconName: string, zIndex: number): boolean
	local imageId = Theme.IconImages and Theme.IconImages[iconName]
	if typeof(imageId) ~= "string" or imageId == "" then
		return false
	end

	local image = Instance.new("ImageLabel")
	image.Name = "AppIconImage"
	image.BackgroundTransparency = 1
	image.Image = imageId
	image.ScaleType = Enum.ScaleType.Fit
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.Position = UDim2.fromScale(0.5, 0.5)
	image.Size = UDim2.fromScale(0.78, 0.78)
	image.ZIndex = zIndex
	image.Parent = parent
	return true
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

local function addAppBadge(parent: Instance, id: string, title: string, zIndex: number)
	local appBadge = Instance.new("Frame")
	appBadge.Name = "AppBadge"
	appBadge.AnchorPoint = Vector2.new(0, 0.5)
	appBadge.Position = UDim2.new(0, 12, 0.5, 0)
	appBadge.Size = UDim2.fromOffset(40, 40)
	appBadge.BackgroundColor3 = Theme.Colors.AccentCream
	appBadge.BorderSizePixel = 0
	appBadge.ZIndex = zIndex
	appBadge.Parent = parent
	addCorner(appBadge, 12)
	addStroke(appBadge, Theme.Colors.AccentPink, 1.8, 0.08)
	addGradient(appBadge, {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 231, 246),
	}, 90)

	local iconName = WINDOW_ICONS[id] or "gem"
	if not addUploadedIcon(appBadge, iconName, zIndex + 3) then
		local glyph = makeText(appBadge, "Glyph", string.upper(string.sub(title, 1, 1)), Theme.Fonts.Title, 18, Theme.Colors.AccentPinkDeep, zIndex + 3)
		glyph.Size = UDim2.fromScale(1, 1)
		glyph.TextXAlignment = Enum.TextXAlignment.Center
	end

	addSparkle(appBadge, UDim2.fromOffset(29, 4), 6, zIndex + 4)
	return appBadge
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

local function addBowDecoration(parent: Instance, position: UDim2, zIndex: number)
	local image = addImageDecoration(parent, "BowDecoration", "bowHeart", position, UDim2.fromOffset(34, 28), zIndex + 4)
	if image then
		return
	end

	local bow = Instance.new("Frame")
	bow.Name = "BowDecoration"
	bow.BackgroundTransparency = 1
	bow.Position = position
	bow.Size = UDim2.fromOffset(56, 40)
	bow.ZIndex = zIndex
	bow.Parent = parent

	local left = Instance.new("Frame")
	left.Name = "LeftWing"
	left.BackgroundColor3 = Theme.Colors.AccentPink
	left.BorderSizePixel = 0
	left.Position = UDim2.fromOffset(2, 7)
	left.Size = UDim2.fromOffset(24, 18)
	left.Rotation = 18
	left.ZIndex = zIndex + 1
	left.Parent = bow
	addCorner(left, 8)
	addStroke(left, Color3.fromRGB(255, 255, 255), 1.25, 0.08)

	local right = left:Clone()
	right.Name = "RightWing"
	right.Position = UDim2.fromOffset(30, 7)
	right.Rotation = -18
	right.Parent = bow

	local leftTail = Instance.new("Frame")
	leftTail.Name = "LeftTail"
	leftTail.BackgroundColor3 = Color3.fromRGB(255, 202, 229)
	leftTail.BorderSizePixel = 0
	leftTail.Position = UDim2.fromOffset(14, 22)
	leftTail.Size = UDim2.fromOffset(11, 17)
	leftTail.Rotation = 23
	leftTail.ZIndex = zIndex + 1
	leftTail.Parent = bow
	addCorner(leftTail, 4)
	addStroke(leftTail, Color3.fromRGB(255, 255, 255), 1, 0.16)

	local rightTail = leftTail:Clone()
	rightTail.Name = "RightTail"
	rightTail.Position = UDim2.fromOffset(32, 22)
	rightTail.Rotation = -23
	rightTail.Parent = bow

	local knot = Instance.new("Frame")
	knot.Name = "GemKnot"
	knot.BackgroundColor3 = Theme.Colors.Gem
	knot.BorderSizePixel = 0
	knot.Position = UDim2.fromOffset(23, 9)
	knot.Size = UDim2.fromOffset(12, 12)
	knot.Rotation = 45
	knot.ZIndex = zIndex + 2
	knot.Parent = bow
	addCorner(knot, 3)
	addStroke(knot, Color3.fromRGB(255, 255, 255), 1.2, 0.03)

	for i, data in ipairs({
		{ 19, 5 },
		{ 28, 3 },
		{ 37, 5 },
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

	addSparkle(bow, UDim2.fromOffset(8, 4), 8, zIndex + 4)
	addSparkle(bow, UDim2.fromOffset(44, 19), 6, zIndex + 4)
end

local function addGemDecoration(parent: Instance, position: UDim2, size: number, zIndex: number)
	local image = addImageDecoration(parent, "GemDecoration", size >= 18 and "gemDiamond" or "gemHeart", position, UDim2.fromOffset(size, size), zIndex + 2)
	if image then
		addSparkle(parent, UDim2.new(position.X.Scale, position.X.Offset + size, position.Y.Scale, position.Y.Offset - 4), 7, zIndex + 4)
		return
	end

	local gemHost = Instance.new("Frame")
	gemHost.Name = "GemDecoration"
	gemHost.BackgroundTransparency = 1
	gemHost.Position = position
	gemHost.Size = UDim2.fromOffset(size + 8, size + 8)
	gemHost.ZIndex = zIndex
	gemHost.Parent = parent
	IconDraw.makeGem(gemHost, size)
	addSparkle(parent, UDim2.new(position.X.Scale, position.X.Offset + size, position.Y.Scale, position.Y.Offset - 4), 7, zIndex + 2)
end

function WindowChrome.create(parent: Instance, id: string, title: string, onClose: (() -> ())?): WindowHandle
	local fullScreen = id == "Gacha"
	local root = Instance.new("Frame")
	root.Name = id .. "Window"
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = closedPosition()
	root.Size = fullScreen and UDim2.fromScale(1, 1) or UDim2.fromScale(0.62, 0.72)
	root.BackgroundColor3 = Theme.Colors.WindowChrome
	root.BorderSizePixel = 0
	root.ClipsDescendants = false
	root.Visible = false
	root.ZIndex = 40
	root.Parent = parent

	local sizeConstraint = Instance.new("UISizeConstraint")
	sizeConstraint.MinSize = Vector2.new(300, 300)
	sizeConstraint.MaxSize = fullScreen and Vector2.new(10000, 10000) or Vector2.new(980, 760)
	sizeConstraint.Parent = root

	addCorner(root, fullScreen and 0 or 12)
	addStroke(root, Theme.Colors.AccentPink, 2, 0.02)

	if not fullScreen then
		local shadow = Instance.new("Frame")
		shadow.Name = "SoftShadow"
		shadow.AnchorPoint = Vector2.new(0.5, 0.5)
		shadow.Position = UDim2.new(0.5, 8, 0.5, 10)
		shadow.Size = UDim2.new(1, 12, 1, 14)
		shadow.BackgroundColor3 = Theme.Colors.Shadow
		shadow.BackgroundTransparency = 0.76
		shadow.BorderSizePixel = 0
		shadow.ZIndex = 39
		shadow.Parent = root
		addCorner(shadow, 16)
	end

	local shell = Instance.new("Frame")
	shell.Name = "Shell"
	shell.BackgroundColor3 = Theme.Colors.WindowChrome
	shell.BorderSizePixel = 0
	shell.Size = UDim2.fromScale(1, 1)
	shell.ClipsDescendants = true
	shell.ZIndex = 40
	shell.Parent = root
	addCorner(shell, fullScreen and 0 or 11)
	addGradient(shell, {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 247, 253),
		Color3.fromRGB(247, 244, 255),
	}, 90)

	local topGlow = Instance.new("Frame")
	topGlow.Name = "TopGlow"
	topGlow.BackgroundColor3 = Theme.Colors.AccentPink
	topGlow.BorderSizePixel = 0
	topGlow.Size = UDim2.new(1, 0, 0, 4)
	topGlow.ZIndex = 45
	topGlow.Parent = shell

	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.BackgroundColor3 = Theme.Colors.TitleBar
	titleBar.BorderSizePixel = 0
	titleBar.Position = UDim2.fromOffset(0, 4)
	titleBar.Size = UDim2.new(1, 0, 0, 52)
	titleBar.Active = true
	titleBar.ZIndex = 42
	titleBar.Parent = shell
	addGradient(titleBar, {
		Color3.fromRGB(255, 239, 249),
		Color3.fromRGB(255, 248, 253),
		Color3.fromRGB(255, 222, 240),
	}, 0)

	addAppBadge(titleBar, id, title, 44)

	local titleLabel = makeText(titleBar, "Title", string.lower(title) .. ".exe", Theme.Fonts.Body, 14, Theme.Colors.TextPrimary, 43)
	titleLabel.Position = UDim2.fromOffset(64, 0)
	titleLabel.Size = UDim2.new(1, -330, 1, 0)

	local livePill = Instance.new("Frame")
	livePill.Name = "LiveStatus"
	livePill.AnchorPoint = Vector2.new(1, 0.5)
	livePill.Position = UDim2.new(1, -126, 0.5, 0)
	livePill.Size = UDim2.fromOffset(82, 26)
	livePill.BackgroundColor3 = Color3.fromRGB(235, 255, 249)
	livePill.BorderSizePixel = 0
	livePill.ZIndex = 43
	livePill.Parent = titleBar
	addCorner(livePill, 11)
	addStroke(livePill, Theme.Colors.AccentMint, 1, 0.35)

	local liveDot = Instance.new("Frame")
	liveDot.Name = "Dot"
	liveDot.AnchorPoint = Vector2.new(0, 0.5)
	liveDot.Position = UDim2.new(0, 9, 0.5, 0)
	liveDot.Size = UDim2.fromOffset(6, 6)
	liveDot.BackgroundColor3 = Theme.Colors.AccentMint
	liveDot.BorderSizePixel = 0
	liveDot.ZIndex = 44
	liveDot.Parent = livePill
	addCorner(liveDot, 3)

	local liveText = makeText(livePill, "Text", "ONLINE", Theme.Fonts.Title, 9, Theme.Colors.TextPrimary, 44)
	liveText.Position = UDim2.fromOffset(20, 0)
	liveText.Size = UDim2.new(1, -22, 1, 0)

	local function makeSystemButton(name: string, color: Color3, order: number, text: string): TextButton
		local button = Instance.new("TextButton")
		button.Name = name
		button.AutoButtonColor = false
		button.BackgroundColor3 = color
		button.BorderSizePixel = 0
		button.AnchorPoint = Vector2.new(1, 0.5)
		button.Position = UDim2.new(1, -10 - (order * 36), 0.5, 0)
		button.Size = UDim2.fromOffset(30, 30)
		button.Font = Theme.Fonts.Title
		button.Text = text
		button.TextSize = 11
		button.TextColor3 = Theme.Colors.TextPrimary
		button.ZIndex = 45
		button.Parent = titleBar
		addCorner(button, 9)
		addStroke(button, Color3.fromRGB(255, 255, 255), 1, 0.2)
		button.MouseEnter:Connect(function()
			TweenUtil.play(button, { BackgroundTransparency = 0.22 }, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
		end)
		button.MouseLeave:Connect(function()
			TweenUtil.play(button, { BackgroundTransparency = 0 }, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
		end)
		return button
	end

	local minimizeButton = makeSystemButton("Minimize", Theme.Colors.Minimize, 2, "_")
	local maximizeButton = makeSystemButton("Maximize", Theme.Colors.Maximize, 1, "[]")
	local closeButton = makeSystemButton("Close", Theme.Colors.CloseRed, 0, "X")

	local menuBar = Instance.new("Frame")
	menuBar.Name = "MenuBar"
	menuBar.BackgroundColor3 = Color3.fromRGB(255, 253, 255)
	menuBar.BorderSizePixel = 0
	menuBar.Position = UDim2.fromOffset(0, 56)
	menuBar.Size = UDim2.new(1, 0, 0, 32)
	menuBar.ZIndex = 42
	menuBar.Parent = shell

	local menuLabel = makeText(menuBar, "Menu", "HOME     VIEW     TOOLS     HELP", Theme.Fonts.Body, 10, Theme.Colors.TextMuted, 43)
	menuLabel.Position = UDim2.fromOffset(22, 0)
	menuLabel.Size = UDim2.new(1, -138, 1, 0)

	local buildLabel = makeText(menuBar, "Build", "FURU OS 2.5", Theme.Fonts.Title, 9, Theme.Colors.AccentPinkDeep, 43)
	buildLabel.AnchorPoint = Vector2.new(1, 0)
	buildLabel.Position = UDim2.new(1, -14, 0, 0)
	buildLabel.Size = UDim2.fromOffset(100, 28)
	buildLabel.TextXAlignment = Enum.TextXAlignment.Right

	local activeLine = Instance.new("Frame")
	activeLine.Name = "ActiveLine"
	activeLine.BackgroundColor3 = Theme.Colors.AccentPink
	activeLine.BorderSizePixel = 0
	activeLine.Position = UDim2.new(0, 22, 1, -3)
	activeLine.Size = UDim2.fromOffset(42, 3)
	activeLine.ZIndex = 44
	activeLine.Parent = menuBar
	addCorner(activeLine, 1)

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundColor3 = Theme.Colors.ContentBg
	content.BorderSizePixel = 0
	content.Position = UDim2.fromOffset(14, 98)
	content.Size = UDim2.new(1, -28, 1, -162)
	content.ClipsDescendants = true
	content.ZIndex = 42
	content.Parent = shell
	addCorner(content, 12)
	addStroke(content, Theme.Colors.AccentPink, 1.5, 0.35)
	addGradient(content, {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 248, 253),
		Color3.fromRGB(248, 246, 255),
	}, 90)

	local footer = Instance.new("Frame")
	footer.Name = "Footer"
	footer.BackgroundColor3 = Color3.fromRGB(255, 239, 249)
	footer.BorderSizePixel = 0
	footer.AnchorPoint = Vector2.new(0, 1)
	footer.Position = UDim2.new(0, 0, 1, 0)
	footer.Size = UDim2.new(1, 0, 0, 56)
	footer.ZIndex = 42
	footer.Parent = shell
	addBowDecoration(shell, UDim2.new(0, 8, 1, -36), 47)
	addGemDecoration(shell, UDim2.new(1, -32, 1, -32), 16, 47)

	local footerLayout = Instance.new("UIListLayout")
	footerLayout.Name = "CommandLayout"
	footerLayout.FillDirection = Enum.FillDirection.Horizontal
	footerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	footerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	footerLayout.Padding = UDim.new(0, 10)
	footerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	footerLayout.Parent = footer

	local handle: WindowHandle = {
		Root = root,
		Content = content,
		Footer = footer,
		TitleLabel = titleLabel,
		_open = false,
		_minimized = false,
		_maximized = false,
	}

	local normalSize = root.Size
	local normalPosition = openPosition(fullScreen)

	local function setMinimized(minimized: boolean)
		handle._minimized = minimized
		content.Visible = not minimized
		menuBar.Visible = not minimized
		footer.Visible = not minimized
		sizeConstraint.MinSize = minimized and Vector2.new(300, 48) or Vector2.new(300, 300)
		local targetSize = minimized and UDim2.new(normalSize.X.Scale, normalSize.X.Offset, 0, 48) or normalSize
		TweenUtil.play(root, { Size = targetSize }, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
	end

	local function setMaximized(maximized: boolean)
		if handle._minimized then
			setMinimized(false)
		end
		handle._maximized = maximized
		if maximized then
			normalSize = root.Size
			normalPosition = root.Position
			TweenUtil.play(root, {
				Position = UDim2.fromScale(0.5, 0.5),
				Size = fullScreen and UDim2.fromScale(1, 1) or UDim2.fromScale(0.88, 0.84),
			}, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
		else
			TweenUtil.play(root, {
				Position = normalPosition,
				Size = normalSize,
			}, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
		end
	end

	function handle:isOpen()
		return self._open
	end

	function handle:setVisible(visible: boolean, instant: boolean?)
		self._open = visible
		if instant then
			root.Visible = visible
			root.Position = visible and openPosition(fullScreen) or closedPosition()
			root.BackgroundTransparency = 0
			return
		end

		if visible then
			if self._minimized then
				setMinimized(false)
			end
			root.Visible = true
			root.Position = closedPosition()
			root.BackgroundTransparency = 0.28
			TweenUtil.play(root, {
				Position = openPosition(fullScreen),
				BackgroundTransparency = 0,
			}, Theme.Tween.WindowTime, Theme.Tween.SlideStyle, Theme.Tween.SlideDir)
		else
			local tween = TweenUtil.play(root, {
				Position = closedPosition(),
				BackgroundTransparency = 0.28,
			}, Theme.Tween.WindowTime, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
			tween.Completed:Connect(function()
				if not self._open then
					root.Visible = false
					root.BackgroundTransparency = 0
				end
			end)
		end
	end

	minimizeButton.Activated:Connect(function()
		setMinimized(not handle._minimized)
	end)
	maximizeButton.Activated:Connect(function()
		setMaximized(not handle._maximized)
	end)
	closeButton.Activated:Connect(function()
		handle:setVisible(false, false)
		if onClose then
			onClose()
		end
	end)

	local dragging = false
	local dragStart = Vector2.zero
	local startPosition = root.Position

	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end)
	titleBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)

	return handle
end

function WindowChrome.addFooterButton(footer: Frame, text: string, order: number, callback: (() -> ())?): TextButton
	local button = Instance.new("TextButton")
	button.Name = text:gsub("%s", ""):gsub("%W", "") .. "Btn"
	button.AutoButtonColor = false
	button.BackgroundColor3 = Theme.Colors.ButtonFill
	button.BorderSizePixel = 0
	button.Size = UDim2.new(0.29, 0, 0, 36)
	button.LayoutOrder = order
	button.Font = Theme.Fonts.Title
	button.Text = text
	button.TextSize = 13
	button.TextColor3 = Theme.Colors.AccentPinkDeep
	button.ZIndex = 43
	button.Parent = footer
	addCorner(button, 8)
	addStroke(button, Theme.Colors.ButtonStroke, 1.5, 0.18)
	addGradient(button, {
		Color3.fromRGB(255, 255, 255),
		Theme.Colors.ButtonFillHover,
	}, 90)

	button.MouseEnter:Connect(function()
		TweenUtil.play(button, { BackgroundColor3 = Theme.Colors.ButtonFillHover }, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
	end)
	button.MouseLeave:Connect(function()
		TweenUtil.play(button, { BackgroundColor3 = Theme.Colors.ButtonFill }, Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
	end)
	if callback then
		button.Activated:Connect(callback)
	end
	return button
end

return WindowChrome
