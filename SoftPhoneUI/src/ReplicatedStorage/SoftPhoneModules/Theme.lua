--[[
	SoftPhoneUI Theme
	White futuristic phone chrome with vibrant pink accents.
]]

local Theme = {}

Theme.Side = "Right"

Theme.Colors = {
	PanelFill = Color3.fromRGB(255, 255, 255),
	PanelFillAlt = Color3.fromRGB(255, 248, 253),
	PanelStroke = Color3.fromRGB(255, 255, 255),
	AccentPink = Color3.fromRGB(255, 190, 222),
	AccentPinkDeep = Color3.fromRGB(232, 95, 166),
	AccentMint = Color3.fromRGB(86, 224, 209),
	AccentLavender = Color3.fromRGB(176, 128, 255),
	AccentBlue = Color3.fromRGB(120, 203, 255),
	AccentCream = Color3.fromRGB(255, 250, 254),
	Gem = Color3.fromRGB(255, 74, 173),
	GemInner = Color3.fromRGB(255, 218, 244),
	TitleBar = Color3.fromRGB(255, 245, 253),
	TitleBarAlt = Color3.fromRGB(255, 202, 229),
	WindowChrome = Color3.fromRGB(255, 255, 255),
	WindowBorder = Color3.fromRGB(238, 208, 232),
	ContentBg = Color3.fromRGB(255, 251, 254),
	ButtonFill = Color3.fromRGB(255, 211, 233),
	ButtonFillHover = Color3.fromRGB(255, 222, 239),
	ButtonStroke = Color3.fromRGB(255, 151, 203),
	TextPrimary = Color3.fromRGB(74, 54, 84),
	TextOnPink = Color3.fromRGB(255, 255, 255),
	TextMuted = Color3.fromRGB(139, 112, 151),
	CloseRed = Color3.fromRGB(255, 88, 126),
	Minimize = Color3.fromRGB(255, 211, 95),
	Maximize = Color3.fromRGB(89, 224, 172),
	SlotBg = Color3.fromRGB(249, 238, 250),
	SlotBgAlt = Color3.fromRGB(238, 249, 255),
	Scrollbar = Color3.fromRGB(255, 139, 204),
	Shadow = Color3.fromRGB(155, 104, 157),
}

Theme.Fonts = {
	Title = Enum.Font.GothamBold,
	Body = Enum.Font.GothamMedium,
	UI = Enum.Font.Gotham,
}

Theme.Sizes = {
	SidebarWidthScale = 0.22,
	SidebarWidthMin = 200,
	SidebarWidthMax = 280,
	SidebarHeightScale = 0.88,
	TabReveal = 32,
	GemSize = 36,
	ButtonHeight = 38,
	CornerRadius = 18,
	WindowCorner = 10,
	WindowWidthScale = 0.58,
	WindowHeightScale = 0.64,
}

Theme.Tween = {
	SlideTime = 0.42,
	SlideStyle = Enum.EasingStyle.Quint,
	SlideDir = Enum.EasingDirection.Out,
	QuickTime = 0.18,
	WindowTime = 0.38,
}

Theme.Buttons = {
	{ Id = "Shop", Label = "Shop", Icon = "bag", Accent = Theme.Colors.AccentPinkDeep },
	{ Id = "Gacha", Label = "Gacha", Icon = "star", Accent = Theme.Colors.AccentLavender },
	{ Id = "Map", Label = "Map", Icon = "map", Accent = Theme.Colors.AccentBlue },
	{ Id = "Messages", Label = "Messages", Icon = "mail", Accent = Theme.Colors.AccentPinkDeep },
	{ Id = "Teleport", Label = "Teleport", Icon = "portal", Accent = Theme.Colors.AccentLavender },
	{ Id = "Job", Label = "Job", Icon = "briefcase", Accent = Theme.Colors.AccentMint },
}

-- Optional Roblox image asset ids after uploading assets/png or assets/generated.
-- Example: bag = "rbxassetid://1234567890"
Theme.IconImages = {
	gem = "rbxassetid://123801663036253",
	bag = "rbxassetid://78667116344761",
	star = "rbxassetid://107219881831454",
	map = "rbxassetid://82322439606303",
	mail = "rbxassetid://87540293204246",
	portal = "rbxassetid://137952940849608",
	briefcase = "rbxassetid://116977598895169",
	capsule = "rbxassetid://132648938590553",
	crystal = "rbxassetid://126962551323488",
	ticket = "rbxassetid://129656404868771",
	constellation = "rbxassetid://112646389569977",
	gift = "rbxassetid://105226340900083",
	city = "rbxassetid://87658912537240",
	pin = "rbxassetid://109242731362340",
	cafe = "rbxassetid://102395837969023",
	mall = "rbxassetid://129969640184829",
	office = "rbxassetid://119416441801055",
	message = "rbxassetid://87540293204246",
	friend = "rbxassetid://103192066320011",
	megaphone = "rbxassetid://75224246235322",
	bell = "rbxassetid://100174367873526",
	reply = "rbxassetid://121506647753651",
	compass = "rbxassetid://133963455361854",
	document = "rbxassetid://110293176551847",
	delivery = "rbxassetid://72311386052094",
}

-- Upload assets/generated/shop_items and paste the six ids here. The shop uses
-- polished native item art until an uploaded image id is available.
Theme.ShopItemImages = {
	pixel_bow_jacket = "rbxassetid://102324325450737",
	starline_skirt = "rbxassetid://137054149355990",
	bubble_boots = "rbxassetid://92795722045701",
	ribbon_satchel = "rbxassetid://71825306308832",
	mint_sleeve_set = "rbxassetid://133446076092208",
	glow_hairclip = "rbxassetid://86930450138088",
}

Theme.DecorationImages = {
	gemHeart = "rbxassetid://124977509470211",
	bowHeart = "rbxassetid://71160719370388",
	bowOval = "rbxassetid://74233855824346",
	gemDiamond = "rbxassetid://93207797663861",
}

return Theme
