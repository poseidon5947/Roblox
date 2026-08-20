--[[
	Glossy UI icon builder.
	Native art remains visible until an optional uploaded image is confirmed loaded.
]]

local Theme = require(script.Parent.Theme)

local IconDraw = {}

local WHITE = Color3.fromRGB(255, 255, 255)
local PINK = Theme.Colors.AccentPinkDeep
local HOT_PINK = Theme.Colors.AccentPink
local LAVENDER = Theme.Colors.AccentLavender
local CYAN = Theme.Colors.AccentBlue
local MINT = Theme.Colors.AccentMint

local function imageId(iconName: string): string?
	local id = Theme.IconImages and Theme.IconImages[iconName]
	if typeof(id) == "string" and id ~= "" then
		return id
	end
	return nil
end

local function corner(parent: Instance, radius: number)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius)
	c.Parent = parent
	return c
end

local function stroke(parent: Instance, color: Color3, thickness: number, transparency: number?)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

local function gradient(parent: Instance, colors: { Color3 }, rotation: number?)
	local keys = {}
	for i, color in ipairs(colors) do
		table.insert(keys, ColorSequenceKeypoint.new((i - 1) / (#colors - 1), color))
	end
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(keys)
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end

local function frame(parent: Instance, name: string, color: Color3, pos: UDim2, size: UDim2, z: number, radius: number?)
	local f = Instance.new("Frame")
	f.Name = name
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Position = pos
	f.Size = size
	f.ZIndex = z
	f.Parent = parent
	if radius then
		corner(f, radius)
	end
	return f
end

local function addImage(parent: Instance, iconName: string, z: number): ImageLabel?
	local id = imageId(iconName)
	if not id then
		return nil
	end
	local img = Instance.new("ImageLabel")
	img.Name = "UploadedIcon"
	img.BackgroundTransparency = 1
	img.Image = id
	img.ScaleType = Enum.ScaleType.Fit
	img.Size = UDim2.fromScale(0.9, 0.9)
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.5)
	img.ZIndex = z
	img.Parent = parent
	corner(img, 999)
	return img
end

function IconDraw.bindImageFallback(image: ImageLabel?, fallback: GuiObject)
	if not image then
		fallback.Visible = true
		return
	end

	local function refresh()
		if fallback.Parent and image.Parent then
			fallback.Visible = not image.IsLoaded
		end
	end
	refresh()
	image:GetPropertyChangedSignal("IsLoaded"):Connect(refresh)
end

local function addShine(parent: Instance, z: number)
	local shine = frame(parent, "Shine", WHITE, UDim2.fromScale(0.16, 0.11), UDim2.fromScale(0.68, 0.24), z, 999)
	shine.BackgroundTransparency = 0.38
	return shine
end

local function drawBag(parent: Instance, z: number)
	local body = frame(parent, "BagBody", WHITE, UDim2.fromScale(0.22, 0.36), UDim2.fromScale(0.56, 0.44), z, 6)
	stroke(body, PINK, 2, 0)
	local handle = frame(parent, "BagHandle", HOT_PINK, UDim2.fromScale(0.34, 0.23), UDim2.fromScale(0.32, 0.2), z, 8)
	handle.BackgroundTransparency = 1
	stroke(handle, PINK, 3, 0)
	local heart = frame(parent, "BagHeart", HOT_PINK, UDim2.fromScale(0.42, 0.5), UDim2.fromScale(0.16, 0.16), z + 1, 3)
	heart.Rotation = 45
end

local function drawGacha(parent: Instance, z: number)
	local globe = frame(parent, "Globe", WHITE, UDim2.fromScale(0.24, 0.18), UDim2.fromScale(0.52, 0.48), z, 999)
	globe.BackgroundTransparency = 0.1
	stroke(globe, PINK, 2, 0.05)
	for i, color in ipairs({ HOT_PINK, LAVENDER, CYAN, MINT }) do
		local x = 0.32 + ((i - 1) % 2) * 0.2
		local y = 0.34 + math.floor((i - 1) / 2) * 0.16
		frame(parent, "Capsule" .. i, color, UDim2.fromScale(x, y), UDim2.fromScale(0.14, 0.14), z + 1, 999)
	end
	local base = frame(parent, "Base", PINK, UDim2.fromScale(0.28, 0.64), UDim2.fromScale(0.44, 0.2), z, 7)
	gradient(base, { HOT_PINK, PINK }, 90)
	stroke(base, WHITE, 1.5, 0)
end

local function drawMap(parent: Instance, z: number)
	local left = frame(parent, "MapLeft", Color3.fromRGB(255, 228, 247), UDim2.fromScale(0.22, 0.36), UDim2.fromScale(0.23, 0.4), z, 4)
	local mid = frame(parent, "MapMid", Color3.fromRGB(225, 245, 255), UDim2.fromScale(0.43, 0.31), UDim2.fromScale(0.24, 0.45), z, 4)
	local right = frame(parent, "MapRight", Color3.fromRGB(244, 231, 255), UDim2.fromScale(0.65, 0.36), UDim2.fromScale(0.17, 0.4), z, 4)
	stroke(left, PINK, 1.4, 0.05)
	stroke(mid, CYAN, 1.4, 0.05)
	stroke(right, LAVENDER, 1.4, 0.05)
	local pin = frame(parent, "Pin", HOT_PINK, UDim2.fromScale(0.48, 0.22), UDim2.fromScale(0.22, 0.22), z + 1, 999)
	stroke(pin, WHITE, 1.5, 0)
	local point = frame(parent, "PinPoint", HOT_PINK, UDim2.fromScale(0.55, 0.39), UDim2.fromScale(0.08, 0.14), z + 1, 2)
	point.Rotation = 45
end

local function drawMail(parent: Instance, z: number)
	local env = frame(parent, "Envelope", WHITE, UDim2.fromScale(0.18, 0.34), UDim2.fromScale(0.64, 0.4), z, 7)
	stroke(env, PINK, 2, 0)
	local flapA = frame(parent, "FlapA", HOT_PINK, UDim2.fromScale(0.22, 0.39), UDim2.fromScale(0.38, 0.06), z + 1, 2)
	flapA.Rotation = 27
	local flapB = frame(parent, "FlapB", HOT_PINK, UDim2.fromScale(0.42, 0.39), UDim2.fromScale(0.38, 0.06), z + 1, 2)
	flapB.Rotation = -27
	local seal = frame(parent, "Seal", HOT_PINK, UDim2.fromScale(0.43, 0.48), UDim2.fromScale(0.14, 0.14), z + 2, 3)
	seal.Rotation = 45
end

local function drawPortal(parent: Instance, z: number)
	local outer = frame(parent, "PortalOuter", CYAN, UDim2.fromScale(0.18, 0.18), UDim2.fromScale(0.64, 0.64), z, 999)
	outer.BackgroundTransparency = 0.18
	stroke(outer, WHITE, 2, 0)
	local inner = frame(parent, "PortalInner", LAVENDER, UDim2.fromScale(0.28, 0.28), UDim2.fromScale(0.44, 0.44), z + 1, 999)
	gradient(inner, { CYAN, HOT_PINK, LAVENDER }, 35)
	stroke(inner, WHITE, 1.5, 0.15)
	local core = frame(parent, "PortalCore", WHITE, UDim2.fromScale(0.42, 0.42), UDim2.fromScale(0.16, 0.16), z + 2, 999)
	core.BackgroundTransparency = 0.12
end

local function drawBriefcase(parent: Instance, z: number)
	local body = frame(parent, "CaseBody", WHITE, UDim2.fromScale(0.18, 0.36), UDim2.fromScale(0.64, 0.42), z, 7)
	stroke(body, PINK, 2, 0)
	local strap = frame(parent, "Strap", HOT_PINK, UDim2.fromScale(0.22, 0.47), UDim2.fromScale(0.56, 0.08), z + 1, 2)
	local handle = frame(parent, "CaseHandle", HOT_PINK, UDim2.fromScale(0.36, 0.24), UDim2.fromScale(0.28, 0.16), z, 6)
	handle.BackgroundTransparency = 1
	stroke(handle, PINK, 2.5, 0)
	local charm = frame(parent, "StarCharm", LAVENDER, UDim2.fromScale(0.56, 0.5), UDim2.fromScale(0.15, 0.15), z + 2, 3)
	charm.Rotation = 45
end

local function drawTicket(parent: Instance, z: number)
	local body = frame(parent, "Ticket", WHITE, UDim2.fromScale(0.14, 0.3), UDim2.fromScale(0.72, 0.4), z, 6)
	stroke(body, PINK, 2, 0)
	local band = frame(parent, "TicketBand", HOT_PINK, UDim2.fromScale(0.22, 0.46), UDim2.fromScale(0.56, 0.08), z + 1, 3)
	local star = frame(parent, "TicketStar", LAVENDER, UDim2.fromScale(0.43, 0.36), UDim2.fromScale(0.14, 0.14), z + 2, 3)
	star.Rotation = 45
end

local function drawConstellation(parent: Instance, z: number)
	local lineA = frame(parent, "LinkA", LAVENDER, UDim2.fromScale(0.28, 0.43), UDim2.fromScale(0.42, 0.04), z, 2)
	lineA.Rotation = 18
	local lineB = frame(parent, "LinkB", CYAN, UDim2.fromScale(0.46, 0.48), UDim2.fromScale(0.3, 0.04), z, 2)
	lineB.Rotation = -42
	for i, data in ipairs({
		{ 0.2, 0.3, HOT_PINK },
		{ 0.62, 0.42, LAVENDER },
		{ 0.42, 0.65, CYAN },
	}) do
		local star = frame(parent, "Star" .. i, data[3], UDim2.fromScale(data[1], data[2]), UDim2.fromScale(0.2, 0.2), z + 1, 4)
		star.Rotation = 45
		stroke(star, WHITE, 1.2, 0.08)
	end
end

local function drawGift(parent: Instance, z: number)
	local box = frame(parent, "GiftBox", WHITE, UDim2.fromScale(0.2, 0.36), UDim2.fromScale(0.6, 0.44), z, 7)
	stroke(box, PINK, 2, 0)
	frame(parent, "RibbonV", HOT_PINK, UDim2.fromScale(0.45, 0.34), UDim2.fromScale(0.1, 0.48), z + 1, 2)
	frame(parent, "RibbonH", HOT_PINK, UDim2.fromScale(0.18, 0.47), UDim2.fromScale(0.64, 0.1), z + 1, 2)
	local bowA = frame(parent, "BowA", LAVENDER, UDim2.fromScale(0.3, 0.2), UDim2.fromScale(0.2, 0.18), z + 2, 6)
	bowA.Rotation = 22
	local bowB = frame(parent, "BowB", LAVENDER, UDim2.fromScale(0.5, 0.2), UDim2.fromScale(0.2, 0.18), z + 2, 6)
	bowB.Rotation = -22
end

local function drawCity(parent: Instance, z: number)
	local buildings = {
		{ 0.17, 0.42, 0.2, 0.34, HOT_PINK },
		{ 0.39, 0.23, 0.24, 0.53, LAVENDER },
		{ 0.65, 0.36, 0.18, 0.4, CYAN },
	}
	for i, data in ipairs(buildings) do
		local building = frame(parent, "Building" .. i, data[5], UDim2.fromScale(data[1], data[2]), UDim2.fromScale(data[3], data[4]), z, 4)
		stroke(building, WHITE, 1.2, 0.08)
		frame(building, "Window", WHITE, UDim2.fromScale(0.28, 0.18), UDim2.fromScale(0.44, 0.16), z + 1, 2)
	end
end

local function drawPin(parent: Instance, z: number)
	local head = frame(parent, "PinHead", HOT_PINK, UDim2.fromScale(0.24, 0.16), UDim2.fromScale(0.52, 0.52), z, 999)
	stroke(head, WHITE, 2, 0)
	local point = frame(parent, "PinPoint", HOT_PINK, UDim2.fromScale(0.4, 0.52), UDim2.fromScale(0.2, 0.3), z, 3)
	point.Rotation = 45
	local center = frame(parent, "PinCenter", WHITE, UDim2.fromScale(0.4, 0.32), UDim2.fromScale(0.2, 0.2), z + 1, 999)
	center.BackgroundTransparency = 0.08
end

local function drawCafe(parent: Instance, z: number)
	local cup = frame(parent, "Cup", WHITE, UDim2.fromScale(0.2, 0.36), UDim2.fromScale(0.52, 0.38), z, 8)
	stroke(cup, PINK, 2, 0)
	local handle = frame(parent, "Handle", WHITE, UDim2.fromScale(0.62, 0.42), UDim2.fromScale(0.22, 0.22), z, 999)
	handle.BackgroundTransparency = 1
	stroke(handle, PINK, 2, 0)
	local foam = frame(parent, "Foam", Color3.fromRGB(255, 222, 236), UDim2.fromScale(0.26, 0.4), UDim2.fromScale(0.4, 0.08), z + 1, 999)
	frame(parent, "Saucer", LAVENDER, UDim2.fromScale(0.15, 0.72), UDim2.fromScale(0.7, 0.08), z, 999)
end

local function drawMall(parent: Instance, z: number)
	local building = frame(parent, "Mall", WHITE, UDim2.fromScale(0.16, 0.3), UDim2.fromScale(0.68, 0.5), z, 6)
	stroke(building, PINK, 2, 0)
	for i, color in ipairs({ HOT_PINK, CYAN, LAVENDER }) do
		frame(parent, "Awning" .. i, color, UDim2.fromScale(0.2 + ((i - 1) * 0.2), 0.42), UDim2.fromScale(0.18, 0.14), z + 1, 3)
	end
	frame(parent, "Door", Color3.fromRGB(230, 246, 255), UDim2.fromScale(0.42, 0.58), UDim2.fromScale(0.16, 0.22), z + 1, 3)
	local bag = frame(parent, "Sign", HOT_PINK, UDim2.fromScale(0.39, 0.18), UDim2.fromScale(0.22, 0.18), z + 1, 5)
	stroke(bag, WHITE, 1, 0.2)
end

local function drawOffice(parent: Instance, z: number)
	local building = frame(parent, "Office", LAVENDER, UDim2.fromScale(0.24, 0.16), UDim2.fromScale(0.52, 0.66), z, 6)
	stroke(building, WHITE, 2, 0)
	for row = 0, 2 do
		for col = 0, 1 do
			frame(building, "Window" .. row .. col, WHITE, UDim2.fromScale(0.18 + col * 0.45, 0.16 + row * 0.22), UDim2.fromScale(0.2, 0.12), z + 1, 2)
		end
	end
	frame(building, "Door", CYAN, UDim2.fromScale(0.38, 0.76), UDim2.fromScale(0.24, 0.24), z + 1, 2)
end

local function drawFriend(parent: Instance, z: number)
	local head = frame(parent, "Head", Color3.fromRGB(255, 224, 240), UDim2.fromScale(0.36, 0.18), UDim2.fromScale(0.28, 0.28), z + 1, 999)
	stroke(head, WHITE, 1.5, 0.1)
	local hair = frame(parent, "Hair", HOT_PINK, UDim2.fromScale(0.32, 0.14), UDim2.fromScale(0.36, 0.18), z + 2, 999)
	local body = frame(parent, "Body", LAVENDER, UDim2.fromScale(0.24, 0.5), UDim2.fromScale(0.52, 0.32), z, 999)
	stroke(body, WHITE, 1.5, 0.08)
	local badge = frame(parent, "FriendBadge", MINT, UDim2.fromScale(0.62, 0.56), UDim2.fromScale(0.22, 0.22), z + 3, 999)
	stroke(badge, WHITE, 1, 0)
end

local function drawMegaphone(parent: Instance, z: number)
	local horn = frame(parent, "Horn", HOT_PINK, UDim2.fromScale(0.22, 0.28), UDim2.fromScale(0.5, 0.38), z, 7)
	horn.Rotation = -8
	gradient(horn, { HOT_PINK, LAVENDER }, 0)
	stroke(horn, WHITE, 1.5, 0.05)
	local mouth = frame(parent, "Mouth", WHITE, UDim2.fromScale(0.62, 0.22), UDim2.fromScale(0.16, 0.5), z + 1, 999)
	stroke(mouth, PINK, 1.5, 0)
	local handle = frame(parent, "Handle", PINK, UDim2.fromScale(0.32, 0.58), UDim2.fromScale(0.15, 0.24), z, 4)
	handle.Rotation = 15
	for i = 1, 2 do
		local sound = frame(parent, "Sound" .. i, CYAN, UDim2.fromScale(0.8, 0.28 + i * 0.16), UDim2.fromScale(0.1, 0.04), z + 1, 2)
		sound.Rotation = (i == 1) and -20 or 20
	end
end

local function drawBell(parent: Instance, z: number)
	local bell = frame(parent, "Bell", HOT_PINK, UDim2.fromScale(0.24, 0.24), UDim2.fromScale(0.52, 0.5), z, 999)
	stroke(bell, WHITE, 2, 0)
	frame(parent, "BellCut", WHITE, UDim2.fromScale(0.2, 0.58), UDim2.fromScale(0.6, 0.18), z + 1, 999)
	frame(parent, "Clapper", LAVENDER, UDim2.fromScale(0.43, 0.7), UDim2.fromScale(0.14, 0.14), z + 2, 999)
	local dot = frame(parent, "Status", MINT, UDim2.fromScale(0.65, 0.16), UDim2.fromScale(0.2, 0.2), z + 3, 999)
	stroke(dot, WHITE, 1.2, 0)
end

local function drawReply(parent: Instance, z: number)
	local bubble = frame(parent, "Bubble", HOT_PINK, UDim2.fromScale(0.16, 0.22), UDim2.fromScale(0.68, 0.5), z, 12)
	stroke(bubble, WHITE, 2, 0)
	local arrow = frame(parent, "ReplyArrow", WHITE, UDim2.fromScale(0.28, 0.43), UDim2.fromScale(0.42, 0.1), z + 1, 3)
	local tip = frame(parent, "ReplyTip", WHITE, UDim2.fromScale(0.26, 0.35), UDim2.fromScale(0.18, 0.18), z + 1, 3)
	tip.Rotation = 45
end

local function drawCompass(parent: Instance, z: number)
	local dial = frame(parent, "Compass", WHITE, UDim2.fromScale(0.18, 0.18), UDim2.fromScale(0.64, 0.64), z, 999)
	stroke(dial, PINK, 2, 0)
	local needleA = frame(parent, "NeedleA", HOT_PINK, UDim2.fromScale(0.46, 0.23), UDim2.fromScale(0.1, 0.34), z + 1, 3)
	needleA.Rotation = 38
	local needleB = frame(parent, "NeedleB", CYAN, UDim2.fromScale(0.46, 0.48), UDim2.fromScale(0.1, 0.28), z + 1, 3)
	needleB.Rotation = 38
	frame(parent, "Hub", LAVENDER, UDim2.fromScale(0.43, 0.43), UDim2.fromScale(0.14, 0.14), z + 2, 999)
end

local function drawDocument(parent: Instance, z: number)
	local page = frame(parent, "Document", WHITE, UDim2.fromScale(0.22, 0.13), UDim2.fromScale(0.56, 0.7), z, 7)
	stroke(page, PINK, 2, 0)
	local clip = frame(parent, "Clip", LAVENDER, UDim2.fromScale(0.36, 0.09), UDim2.fromScale(0.28, 0.16), z + 1, 5)
	stroke(clip, WHITE, 1, 0.1)
	for i = 1, 3 do
		frame(parent, "Line" .. i, i == 3 and MINT or HOT_PINK, UDim2.fromScale(0.31, 0.32 + i * 0.13), UDim2.fromScale(0.38, 0.05), z + 1, 2)
	end
end

local function drawDelivery(parent: Instance, z: number)
	local tray = frame(parent, "Tray", LAVENDER, UDim2.fromScale(0.13, 0.68), UDim2.fromScale(0.74, 0.1), z, 999)
	stroke(tray, WHITE, 1.2, 0.08)
	local cup = frame(parent, "Cup", WHITE, UDim2.fromScale(0.2, 0.3), UDim2.fromScale(0.36, 0.38), z + 1, 7)
	stroke(cup, PINK, 1.8, 0)
	frame(parent, "Lid", HOT_PINK, UDim2.fromScale(0.18, 0.27), UDim2.fromScale(0.4, 0.08), z + 2, 3)
	local parcel = frame(parent, "Parcel", MINT, UDim2.fromScale(0.58, 0.43), UDim2.fromScale(0.24, 0.24), z + 1, 4)
	stroke(parcel, WHITE, 1.2, 0.1)
	frame(parcel, "Tape", WHITE, UDim2.fromScale(0.4, 0), UDim2.fromScale(0.2, 1), z + 2, 1)
end

local function drawGemIcon(parent: Instance, z: number)
	local diamond = frame(parent, "Diamond", HOT_PINK, UDim2.fromScale(0.3, 0.3), UDim2.fromScale(0.4, 0.4), z, 5)
	diamond.Rotation = 45
	gradient(diamond, { Color3.fromRGB(255, 240, 251), HOT_PINK, LAVENDER }, 90)
	stroke(diamond, WHITE, 1.8, 0.02)
	local shine = frame(parent, "GemShine", WHITE, UDim2.fromScale(0.37, 0.28), UDim2.fromScale(0.12, 0.12), z + 1, 2)
	shine.Rotation = 45
end

local DRAWERS = {
	bag = drawBag,
	star = drawGacha,
	capsule = drawGacha,
	ticket = drawTicket,
	constellation = drawConstellation,
	gift = drawGift,
	map = drawMap,
	city = drawCity,
	pin = drawPin,
	cafe = drawCafe,
	mall = drawMall,
	office = drawOffice,
	mail = drawMail,
	message = drawMail,
	friend = drawFriend,
	megaphone = drawMegaphone,
	bell = drawBell,
	reply = drawReply,
	portal = drawPortal,
	compass = drawCompass,
	briefcase = drawBriefcase,
	document = drawDocument,
	delivery = drawDelivery,
	gem = drawGemIcon,
	crystal = drawGemIcon,
}

function IconDraw.makeCircleIcon(parent: Instance, iconName: string, color: Color3?): Frame
	local parentZ = parent:IsA("GuiObject") and parent.ZIndex or 1
	local wrap = frame(parent, "IconCircle", color or Theme.Colors.AccentCream, UDim2.new(0, 8, 0.5, 0), UDim2.fromOffset(32, 32), parentZ + 1, 999)
	wrap.AnchorPoint = Vector2.new(0, 0.5)
	wrap.ClipsDescendants = true
	stroke(wrap, Theme.Colors.PanelStroke, 1.5, 0.1)
	gradient(wrap, { WHITE, Theme.Colors.AccentCream, Color3.fromRGB(245, 236, 255) }, 90)
	addShine(wrap, parentZ + 2)

	local fallback = frame(wrap, "NativeIcon", WHITE, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), parentZ + 3)
	fallback.BackgroundTransparency = 1
	local drawer = DRAWERS[iconName]
	if drawer then
		drawer(fallback, parentZ + 3)
	end
	IconDraw.bindImageFallback(addImage(wrap, iconName, parentZ + 6), fallback)

	return wrap
end

function IconDraw.makeGem(parent: Instance, size: number): Frame
	local z = parent:IsA("GuiObject") and parent.ZIndex + 1 or 1
	local wrap = frame(parent, "GemArt", Theme.Colors.Gem, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(size, size), z, 7)
	wrap.AnchorPoint = Vector2.new(0.5, 0.5)
	wrap.Rotation = 45
	gradient(wrap, { Color3.fromRGB(255, 244, 252), HOT_PINK, PINK, LAVENDER }, 90)
	stroke(wrap, WHITE, 2.5, 0)

	local fallback = frame(wrap, "NativeGem", WHITE, UDim2.fromScale(0, 0), UDim2.fromScale(1, 1), z + 1)
	fallback.BackgroundTransparency = 1
	local facetA = frame(fallback, "FacetA", Color3.fromRGB(255, 230, 248), UDim2.fromScale(0.1, 0.12), UDim2.fromScale(0.5, 0.22), z + 1, 3)
	facetA.BackgroundTransparency = 0.12
	local facetB = frame(fallback, "FacetB", Color3.fromRGB(255, 113, 195), UDim2.fromScale(0.48, 0.2), UDim2.fromScale(0.28, 0.54), z + 1, 3)
	facetB.BackgroundTransparency = 0.2
	local sparkle = frame(fallback, "Sparkle", WHITE, UDim2.fromScale(0.23, 0.22), UDim2.fromScale(0.13, 0.13), z + 2, 2)
	sparkle.Rotation = 45
	IconDraw.bindImageFallback(addImage(wrap, "gem", z + 5), fallback)
	return wrap
end

return IconDraw
