--[[
	Feature dashboards for Gacha, Map, Messages, Teleport, and Job.
	Each feature owns one dedicated .exe window with a responsive scrolling body.
]]

local Theme = require(script.Parent.Theme)
local IconDraw = require(script.Parent.IconDraw)
local WindowChrome = require(script.Parent.WindowChrome)

local PlaceholderWindows = {}

local SPECS = {
	Gacha = {
		Title = "gacha",
		Eyebrow = "CAPSULE LAB",
		Headline = "Lucky streak ready",
		Subline = "Your next sparkle is waiting.",
		Icon = "star",
		FeaturedIcon = "capsule",
		TaskIcons = { "ticket", "constellation" },
		Metrics = { { "PITY", "42 / 80" }, { "TOKENS", "8" } },
		Section = "FEATURED CAPSULE",
		Featured = "Celestial Ribbon",
		Description = "Pastel halos, ribbon trails, and one limited aura.",
		Reward = "150 GEMS",
		Action = "Preview Pool",
		Tasks = {
			{ "Daily Wish", "Use one free pull", "READY", 1 },
			{ "Star Collector", "Collect 3 capsule stars", "2 / 3", 0.66 },
		},
		Footer = { "Pull x1", "Pull x10", "History" },
	},
	Map = {
		Title = "map",
		Eyebrow = "FURU NAV",
		Headline = "Moonlight District",
		Subline = "3 nearby activities are active.",
		Icon = "map",
		FeaturedIcon = "city",
		TaskIcons = { "cafe", "office" },
		Metrics = { { "PINS", "12" }, { "FOUND", "68%" } },
		Section = "RECOMMENDED STOP",
		Featured = "Moonlight Plaza",
		Description = "Shopping, gacha kiosks, and the evening fountain show.",
		Reward = "240m AWAY",
		Action = "Set Route",
		Tasks = {
			{ "Cafe Lumi", "New seasonal menu", "OPEN", 0.8 },
			{ "Job Hub", "Two bonus shifts", "+20%", 0.55 },
		},
		Footer = { "Zoom", "Pins", "Home" },
	},
	Messages = {
		Title = "messages",
		Eyebrow = "FURU MAIL",
		Headline = "Good afternoon",
		Subline = "You have 3 unread messages.",
		Icon = "mail",
		FeaturedIcon = "megaphone",
		TaskIcons = { "friend", "bell" },
		Metrics = { { "UNREAD", "3" }, { "FRIENDS", "18" } },
		Section = "LATEST MESSAGE",
		Featured = "Welcome to Moonlight Plaza",
		Description = "The fountain event begins tonight. Bring a friend for a bonus.",
		Reward = "2m AGO",
		Action = "Open Message",
		Tasks = {
			{ "Mika", "Meet me by the boutique!", "NEW", 0.92 },
			{ "Furu System", "Daily reward delivered", "READ", 1 },
		},
		Footer = { "Compose", "Inbox", "Archive" },
	},
	Teleport = {
		Title = "teleport",
		Eyebrow = "QUICK TRAVEL",
		Headline = "Where to next?",
		Subline = "Travel points are online.",
		Icon = "portal",
		FeaturedIcon = "compass",
		TaskIcons = { "mall", "office" },
		Metrics = { { "POINTS", "7" }, { "COST", "FREE" } },
		Section = "POPULAR DESTINATION",
		Featured = "Furu Central Plaza",
		Description = "The fastest route to shops, events, and daily rewards.",
		Reward = "INSTANT",
		Action = "Teleport",
		Tasks = {
			{ "Fashion Mall", "Boutiques and salon", "ONLINE", 1 },
			{ "Job Hub", "Careers and shifts", "ONLINE", 1 },
		},
		Footer = { "Plaza", "Mall", "Job Hub" },
	},
	Job = {
		Title = "job",
		Eyebrow = "CAREER DESK",
		Headline = "FuruUser",
		Subline = "Intern  |  Level 1  |  120 / 500 XP",
		Icon = "briefcase",
		FeaturedIcon = "office",
		TaskIcons = { "document", "delivery" },
		Metrics = { { "BONUS", "200" }, { "REP", "1" } },
		Section = "FEATURED CAREER",
		Featured = "Office Assistant",
		Description = "Organize documents, assist staff, and complete daily tasks.",
		Reward = "150 GEMS",
		Action = "Start Job",
		Tasks = {
			{ "File Documents", "Complete ten files", "6 / 10", 0.6 },
			{ "Morning Delivery", "Deliver three orders", "1 / 3", 0.33 },
		},
		Footer = { "Apply", "Shifts", "Pay" },
	},
}

local function corner(parent: Instance, radius: number)
	local item = Instance.new("UICorner")
	item.CornerRadius = UDim.new(0, radius)
	item.Parent = parent
	return item
end

local function stroke(parent: Instance, color: Color3, thickness: number, transparency: number?)
	local item = Instance.new("UIStroke")
	item.Color = color
	item.Thickness = thickness
	item.Transparency = transparency or 0
	item.Parent = parent
	return item
end

local function gradient(parent: Instance, colors: { Color3 }, rotation: number?)
	local points = {}
	for i, color in ipairs(colors) do
		table.insert(points, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color))
	end
	local item = Instance.new("UIGradient")
	item.Color = ColorSequence.new(points)
	item.Rotation = rotation or 0
	item.Parent = parent
	return item
end

local function label(parent: Instance, name: string, text: string, size: number, font: Enum.Font, color: Color3, z: number)
	local item = Instance.new("TextLabel")
	item.Name = name
	item.BackgroundTransparency = 1
	item.Font = font
	item.Text = text
	item.TextSize = size
	item.TextColor3 = color
	item.TextXAlignment = Enum.TextXAlignment.Left
	item.ZIndex = z
	item.Parent = parent
	return item
end

local function panel(parent: Instance, name: string, position: UDim2, size: UDim2, color: Color3, z: number)
	local item = Instance.new("Frame")
	item.Name = name
	item.BackgroundColor3 = color
	item.BorderSizePixel = 0
	item.Position = position
	item.Size = size
	item.ZIndex = z
	item.Parent = parent
	corner(item, 8)
	stroke(item, Theme.Colors.AccentPink, 1, 0.52)
	return item
end

local function addMetric(parent: Instance, metric: { string }, order: number)
	local metricPanel = panel(
		parent,
		"Metric" .. order,
		UDim2.new(1, -150 + ((order - 1) * 70), 0, 10),
		UDim2.fromOffset(62, 62),
		Color3.fromRGB(255, 250, 253),
		47
	)

	local value = label(metricPanel, "Value", metric[2], 15, Theme.Fonts.Title, Theme.Colors.TextPrimary, 48)
	value.Position = UDim2.fromOffset(6, 8)
	value.Size = UDim2.new(1, -12, 0, 22)
	value.TextXAlignment = Enum.TextXAlignment.Center
	value.TextTruncate = Enum.TextTruncate.AtEnd

	local name = label(metricPanel, "Name", metric[1], 8, Theme.Fonts.Title, Theme.Colors.AccentPinkDeep, 48)
	name.Position = UDim2.fromOffset(4, 34)
	name.Size = UDim2.new(1, -8, 0, 16)
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.TextTruncate = Enum.TextTruncate.AtEnd
end

local function addProgress(parent: Instance, amount: number, position: UDim2, size: UDim2)
	local track = Instance.new("Frame")
	track.Name = "ProgressTrack"
	track.BackgroundColor3 = Color3.fromRGB(241, 225, 239)
	track.BorderSizePixel = 0
	track.Position = position
	track.Size = size
	track.ZIndex = 48
	track.Parent = parent
	corner(track, 5)

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Theme.Colors.AccentPink
	fill.BorderSizePixel = 0
	fill.Size = UDim2.new(math.clamp(amount, 0.05, 1), 0, 1, 0)
	fill.ZIndex = 49
	fill.Parent = track
	corner(fill, 5)
	gradient(fill, { Theme.Colors.AccentPink, Theme.Colors.AccentLavender }, 0)
end

local function addCenteredIcon(parent: Instance, iconName: string, size: number)
	local icon = IconDraw.makeCircleIcon(parent, iconName, Color3.fromRGB(255, 250, 253))
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.Size = UDim2.fromOffset(size, size)
	return icon
end

local function addTask(parent: Instance, task: { any }, order: number, iconName: string)
	local xScale = order == 1 and 0 or 0.5
	local xOffset = order == 1 and 0 or 5
	local widthOffset = order == 1 and -5 or -5
	local taskPanel = panel(parent, "Task" .. order, UDim2.new(xScale, xOffset, 0, 280), UDim2.new(0.5, widthOffset, 0, 104), Color3.fromRGB(255, 253, 255), 46)

	local iconTile = Instance.new("Frame")
	iconTile.Name = "IconTile"
	iconTile.BackgroundColor3 = Color3.fromRGB(255, 225, 244)
	iconTile.BorderSizePixel = 0
	iconTile.Position = UDim2.fromOffset(10, 12)
	iconTile.Size = UDim2.fromOffset(48, 48)
	iconTile.ZIndex = 47
	iconTile.Parent = taskPanel
	corner(iconTile, 10)
	gradient(iconTile, { Color3.fromRGB(255, 237, 249), Color3.fromRGB(244, 231, 255) }, 90)
	addCenteredIcon(iconTile, iconName, 34)

	local title = label(taskPanel, "Title", task[1], 12, Theme.Fonts.Title, Theme.Colors.TextPrimary, 47)
	title.Position = UDim2.fromOffset(68, 10)
	title.Size = UDim2.new(1, -128, 0, 20)
	title.TextTruncate = Enum.TextTruncate.AtEnd

	local state = label(taskPanel, "State", task[3], 9, Theme.Fonts.Title, Theme.Colors.AccentPinkDeep, 47)
	state.AnchorPoint = Vector2.new(1, 0)
	state.Position = UDim2.new(1, -8, 0, 12)
	state.Size = UDim2.fromOffset(54, 16)
	state.TextXAlignment = Enum.TextXAlignment.Right

	local description = label(taskPanel, "Description", task[2], 10, Theme.Fonts.Body, Theme.Colors.TextMuted, 47)
	description.Position = UDim2.fromOffset(68, 32)
	description.Size = UDim2.new(1, -78, 0, 30)
	description.TextWrapped = true
	description.TextYAlignment = Enum.TextYAlignment.Top

	addProgress(taskPanel, task[4], UDim2.new(0, 12, 1, -20), UDim2.new(1, -24, 0, 7))
	return taskPanel
end

local function paintDashboard(content: Frame, spec)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Dashboard"
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.CanvasSize = UDim2.fromOffset(0, 402)
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = Theme.Colors.Scrollbar
	scroll.ScrollingDirection = Enum.ScrollingDirection.Y
	scroll.ZIndex = 45
	scroll.Parent = content

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingLeft = UDim.new(0, 10)
	padding.PaddingRight = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = scroll

	local profile = panel(scroll, "ProfileStrip", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 82), Color3.fromRGB(255, 253, 255), 46)
	gradient(profile, { Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 241, 250) }, 0)

	local iconWrap = Instance.new("Frame")
	iconWrap.Name = "FeatureIcon"
	iconWrap.BackgroundColor3 = Theme.Colors.AccentPink
	iconWrap.BorderSizePixel = 0
	iconWrap.Position = UDim2.fromOffset(10, 10)
	iconWrap.Size = UDim2.fromOffset(62, 62)
	iconWrap.ZIndex = 47
	iconWrap.Parent = profile
	corner(iconWrap, 16)
	gradient(iconWrap, { Theme.Colors.AccentPink, Theme.Colors.AccentLavender }, 45)
	addCenteredIcon(iconWrap, spec.Icon, 42)

	local eyebrow = label(profile, "Eyebrow", spec.Eyebrow, 9, Theme.Fonts.Title, Theme.Colors.AccentPinkDeep, 47)
	eyebrow.Position = UDim2.fromOffset(82, 10)
	eyebrow.Size = UDim2.new(1, -242, 0, 14)

	local headline = label(profile, "Headline", spec.Headline, 16, Theme.Fonts.Title, Theme.Colors.TextPrimary, 47)
	headline.Position = UDim2.fromOffset(82, 25)
	headline.Size = UDim2.new(1, -242, 0, 24)
	headline.TextTruncate = Enum.TextTruncate.AtEnd

	local subline = label(profile, "Subline", spec.Subline, 10, Theme.Fonts.Body, Theme.Colors.TextMuted, 47)
	subline.Position = UDim2.fromOffset(82, 51)
	subline.Size = UDim2.new(1, -242, 0, 18)
	subline.TextTruncate = Enum.TextTruncate.AtEnd

	for i, metric in ipairs(spec.Metrics) do
		addMetric(profile, metric, i)
	end

	local section = label(scroll, "SectionTitle", spec.Section, 11, Theme.Fonts.Title, Theme.Colors.TextPrimary, 46)
	section.Position = UDim2.fromOffset(4, 92)
	section.Size = UDim2.new(1, -8, 0, 20)

	local featured = panel(scroll, "Featured", UDim2.fromOffset(0, 116), UDim2.new(1, 0, 0, 126), Color3.fromRGB(255, 252, 255), 46)
	gradient(featured, {
		Color3.fromRGB(255, 255, 255),
		Color3.fromRGB(255, 238, 249),
		Color3.fromRGB(243, 240, 255),
	}, 0)
	stroke(featured, Theme.Colors.AccentPink, 1.5, 0.18)

	local featureTile = Instance.new("Frame")
	featureTile.Name = "ArtTile"
	featureTile.BackgroundColor3 = Theme.Colors.AccentPink
	featureTile.BorderSizePixel = 0
	featureTile.Position = UDim2.fromOffset(12, 14)
	featureTile.Size = UDim2.fromOffset(82, 82)
	featureTile.ZIndex = 47
	featureTile.Parent = featured
	corner(featureTile, 14)
	gradient(featureTile, { Theme.Colors.AccentPink, Theme.Colors.AccentLavender, Theme.Colors.AccentBlue }, 45)
	addCenteredIcon(featureTile, spec.FeaturedIcon, 52)

	local featuredTitle = label(featured, "Title", spec.Featured, 17, Theme.Fonts.Title, Theme.Colors.TextPrimary, 47)
	featuredTitle.Position = UDim2.fromOffset(108, 13)
	featuredTitle.Size = UDim2.new(1, -242, 0, 26)
	featuredTitle.TextTruncate = Enum.TextTruncate.AtEnd

	local reward = label(featured, "Reward", spec.Reward, 10, Theme.Fonts.Title, Theme.Colors.AccentPinkDeep, 47)
	reward.AnchorPoint = Vector2.new(1, 0)
	reward.Position = UDim2.new(1, -12, 0, 18)
	reward.Size = UDim2.fromOffset(120, 18)
	reward.TextXAlignment = Enum.TextXAlignment.Right

	local description = label(featured, "Description", spec.Description, 11, Theme.Fonts.Body, Theme.Colors.TextMuted, 47)
	description.Position = UDim2.fromOffset(108, 43)
	description.Size = UDim2.new(1, -124, 0, 38)
	description.TextWrapped = true
	description.TextYAlignment = Enum.TextYAlignment.Top

	local action = Instance.new("TextButton")
	action.Name = "PrimaryAction"
	action.AnchorPoint = Vector2.new(1, 1)
	action.Position = UDim2.new(1, -12, 1, -12)
	action.Size = UDim2.fromOffset(152, 30)
	action.BackgroundColor3 = Theme.Colors.ButtonFill
	action.BorderSizePixel = 0
	action.AutoButtonColor = false
	action.Font = Theme.Fonts.Title
	action.Text = spec.Action
	action.TextColor3 = Theme.Colors.AccentPinkDeep
	action.TextSize = 11
	action.ZIndex = 48
	action.Parent = featured
	corner(action, 7)
	stroke(action, Theme.Colors.ButtonStroke, 1, 0.18)
	action.Activated:Connect(function()
		action.Text = "SELECTED"
		task.delay(1.1, function()
			if action.Parent then
				action.Text = spec.Action
			end
		end)
	end)

	local taskHeading = label(scroll, "TaskHeading", "ACTIVE CARDS", 11, Theme.Fonts.Title, Theme.Colors.TextPrimary, 46)
	taskHeading.Position = UDim2.fromOffset(4, 252)
	taskHeading.Size = UDim2.new(1, -8, 0, 20)

	local taskPanels = {}
	for i, taskSpec in ipairs(spec.Tasks) do
		taskPanels[i] = addTask(scroll, taskSpec, i, spec.TaskIcons[i])
	end

	local function updateTaskLayout()
		if scroll.AbsoluteSize.X < 520 then
			taskPanels[1].Position = UDim2.fromOffset(0, 280)
			taskPanels[1].Size = UDim2.new(1, 0, 0, 104)
			taskPanels[2].Position = UDim2.fromOffset(0, 394)
			taskPanels[2].Size = UDim2.new(1, 0, 0, 104)
			scroll.CanvasSize = UDim2.fromOffset(0, 516)
		else
			taskPanels[1].Position = UDim2.new(0, 0, 0, 280)
			taskPanels[1].Size = UDim2.new(0.5, -5, 0, 104)
			taskPanels[2].Position = UDim2.new(0.5, 5, 0, 280)
			taskPanels[2].Size = UDim2.new(0.5, -5, 0, 104)
			scroll.CanvasSize = UDim2.fromOffset(0, 402)
		end
	end

	task.defer(updateTaskLayout)
	scroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateTaskLayout)
end

function PlaceholderWindows.mountAll(parent: Instance, onCloseFactory: (id: string) -> (() -> ()))
	local windows = {}
	for id, spec in pairs(SPECS) do
		local handle = WindowChrome.create(parent, id, spec.Title, onCloseFactory(id))
		paintDashboard(handle.Content, spec)
		for i, footerLabel in ipairs(spec.Footer) do
			WindowChrome.addFooterButton(handle.Footer, footerLabel, i, nil)
		end
		windows[id] = handle
	end
	return windows
end

return PlaceholderWindows
