--[[
	Shop window with a centered R15 avatar try-on preview.
	Catalog/apply hooks can replace the sample item callbacks later.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Theme = require(script.Parent.Theme)
local WindowChrome = require(script.Parent.WindowChrome)

local ShopWindow = {}

local SAMPLE_ITEMS = {
	{ Key = "pixel_bow_jacket", Name = "Pixel Bow Jacket", Price = 120, Color = Theme.Colors.AccentPink, Tag = "NEW", Category = "CLOTHES", Description = "A plush cropped jacket finished with a heart-gem bow." },
	{ Key = "starline_skirt", Name = "Starline Skirt", Price = 90, Color = Theme.Colors.AccentLavender, Tag = "RARE", Category = "CLOTHES", Description = "Layered lavender tulle with a soft constellation shimmer." },
	{ Key = "bubble_boots", Name = "Bubble Boots", Price = 150, Color = Theme.Colors.AccentBlue, Tag = "TRENDING", Category = "CLOTHES", Description = "Glossy platform boots with cloud-blue translucent soles." },
	{ Key = "ribbon_satchel", Name = "Ribbon Satchel", Price = 75, Color = Theme.Colors.AccentPinkDeep, Tag = "CUTE", Category = "ACCESSORIES", Description = "A compact pearl-handle bag with a satin ribbon clasp." },
	{ Key = "mint_sleeve_set", Name = "Mint Sleeve Set", Price = 40, Color = Theme.Colors.AccentMint, Tag = "SET", Category = "CLOTHES", Description = "Mint puff sleeves with polished cuffs and a soft sheen." },
	{ Key = "glow_hairclip", Name = "Glow Hairclip", Price = 55, Color = Theme.Colors.AccentLavender, Tag = "LIMITED", Category = "ACCESSORIES", Description = "A tiny crystal clip with dangling pastel star charms." },
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
	item.Rotation = rotation or 90
	item.Parent = parent
	return item
end

local function artPart(parent: Instance, name: string, color: Color3, position: UDim2, size: UDim2, radius: number, rotation: number?)
	local item = Instance.new("Frame")
	item.Name = name
	item.BackgroundColor3 = color
	item.BorderSizePixel = 0
	item.Position = position
	item.Size = size
	item.Rotation = rotation or 0
	item.ZIndex = (parent:IsA("GuiObject") and parent.ZIndex or 44) + 1
	item.Parent = parent
	corner(item, radius)
	return item
end


local function drawNativeItem(parent: Instance, item)
	local pink = Theme.Colors.AccentPink
	local deep = Theme.Colors.AccentPinkDeep
	local lavender = Theme.Colors.AccentLavender
	local mint = Theme.Colors.AccentMint
	local cyan = Theme.Colors.AccentBlue
	local white = Color3.fromRGB(255, 255, 255)

	if item.Key == "pixel_bow_jacket" then
		local body = artPart(parent, "JacketBody", item.Color, UDim2.fromScale(0.3, 0.28), UDim2.fromScale(0.4, 0.46), 8)
		stroke(body, white, 2, 0.12)
		artPart(parent, "LeftSleeve", Color3.fromRGB(255, 174, 220), UDim2.fromScale(0.14, 0.31), UDim2.fromScale(0.23, 0.4), 12, 8)
		artPart(parent, "RightSleeve", Color3.fromRGB(255, 174, 220), UDim2.fromScale(0.63, 0.31), UDim2.fromScale(0.23, 0.4), 12, -8)
		local bowLeft = artPart(parent, "BowLeft", deep, UDim2.fromScale(0.34, 0.26), UDim2.fromScale(0.18, 0.16), 5, 18)
		local bowRight = artPart(parent, "BowRight", deep, UDim2.fromScale(0.48, 0.26), UDim2.fromScale(0.18, 0.16), 5, -18)
		stroke(bowLeft, white, 1, 0.2)
		stroke(bowRight, white, 1, 0.2)
	elseif item.Key == "starline_skirt" then
		for i, data in ipairs({ { 0.2, 0.34, 0.6, 0.42 }, { 0.14, 0.47, 0.72, 0.32 }, { 0.09, 0.6, 0.82, 0.22 } }) do
			local layer = artPart(parent, "SkirtLayer" .. i, Color3.fromRGB(193 - i * 8, 144 + i * 10, 255), UDim2.fromScale(data[1], data[2]), UDim2.fromScale(data[3], data[4]), 12)
			stroke(layer, white, 1.5, 0.2)
		end
		artPart(parent, "Waist", lavender, UDim2.fromScale(0.31, 0.24), UDim2.fromScale(0.38, 0.14), 7)
	elseif item.Key == "bubble_boots" then
		for i, x in ipairs({ 0.18, 0.52 }) do
			local boot = artPart(parent, "Boot" .. i, Color3.fromRGB(255, 148, 211), UDim2.fromScale(x, 0.26), UDim2.fromScale(0.3, 0.48), 10)
			stroke(boot, white, 1.5, 0.1)
			local sole = artPart(parent, "Sole" .. i, cyan, UDim2.fromScale(x - 0.03, 0.66), UDim2.fromScale(0.36, 0.18), 9)
			gradient(sole, { cyan, Color3.fromRGB(184, 242, 255), lavender }, 0)
		end
	elseif item.Key == "ribbon_satchel" then
		local bag = artPart(parent, "Satchel", Color3.fromRGB(255, 151, 207), UDim2.fromScale(0.18, 0.32), UDim2.fromScale(0.64, 0.5), 22)
		stroke(bag, white, 2, 0.08)
		local handle = artPart(parent, "PearlHandle", white, UDim2.fromScale(0.28, 0.18), UDim2.fromScale(0.44, 0.24), 999)
		handle.BackgroundTransparency = 1
		stroke(handle, Color3.fromRGB(255, 220, 239), 4, 0)
		artPart(parent, "Ribbon", deep, UDim2.fromScale(0.37, 0.5), UDim2.fromScale(0.26, 0.18), 7, 45)
	elseif item.Key == "mint_sleeve_set" then
		for i, x in ipairs({ 0.2, 0.56 }) do
			local sleeve = artPart(parent, "Sleeve" .. i, mint, UDim2.fromScale(x, 0.24), UDim2.fromScale(0.24, 0.58), 999)
			gradient(sleeve, { Color3.fromRGB(232, 255, 250), mint, Color3.fromRGB(182, 241, 225) }, 90)
			stroke(sleeve, white, 1.5, 0.1)
			artPart(parent, "Cuff" .. i, white, UDim2.fromScale(x - 0.02, 0.7), UDim2.fromScale(0.28, 0.12), 6)
		end
	else
		local crystal = artPart(parent, "CrystalStar", Color3.fromRGB(255, 98, 183), UDim2.fromScale(0.28, 0.2), UDim2.fromScale(0.44, 0.44), 7, 45)
		gradient(crystal, { Color3.fromRGB(255, 235, 249), pink, lavender }, 45)
		stroke(crystal, white, 2, 0.05)
		for i, x in ipairs({ 0.36, 0.5, 0.64 }) do
			artPart(parent, "Charm" .. i, i == 2 and cyan or pink, UDim2.fromScale(x, 0.62), UDim2.fromScale(0.08, 0.18 + i * 0.02), 999)
		end
	end
end

local function renderItemArt(parent: Instance, item)
	for _, child in ipairs(parent:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end

	local imageId = Theme.ShopItemImages and Theme.ShopItemImages[item.Key]
	if typeof(imageId) == "string" and imageId ~= "" then
		local image = Instance.new("ImageLabel")
		image.Name = "ProductImage"
		image.BackgroundTransparency = 1
		image.Size = UDim2.fromScale(1, 1)
		image.Image = imageId
		image.ScaleType = Enum.ScaleType.Crop
		image.ZIndex = (parent:IsA("GuiObject") and parent.ZIndex or 44) + 1
		image.Parent = parent
		corner(image, 9)
		return
	end

	local canvas = Instance.new("Frame")
	canvas.Name = "NativeProductArt"
	canvas.BackgroundColor3 = Color3.fromRGB(255, 244, 252)
	canvas.BorderSizePixel = 0
	canvas.Size = UDim2.fromScale(1, 1)
	canvas.ClipsDescendants = true
	canvas.ZIndex = (parent:IsA("GuiObject") and parent.ZIndex or 44) + 1
	canvas.Parent = parent
	corner(canvas, 9)
	gradient(canvas, { Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 230, 247), Color3.fromRGB(242, 239, 255) }, 90)
	drawNativeItem(canvas, item)
end

local function clearViewport(world: WorldModel)
	for _, child in ipairs(world:GetChildren()) do
		child:Destroy()
	end
end

local function stripScripts(root: Instance)
	for _, d in ipairs(root:GetDescendants()) do
		if d:IsA("BaseScript") then
			d:Destroy()
		end
	end
end

local function setupCamera(viewport: ViewportFrame, model: Model)
	local camera = viewport:FindFirstChild("PreviewCamera")
	if not camera or not camera:IsA("Camera") then
		camera = Instance.new("Camera")
		camera.Name = "PreviewCamera"
		camera.FieldOfView = 38
		camera.Parent = viewport
	end
	viewport.CurrentCamera = camera

	local cf, size = model:GetBoundingBox()
	local viewportSize = viewport.AbsoluteSize
	local aspect = viewportSize.X > 0 and viewportSize.Y > 0 and viewportSize.X / viewportSize.Y or 1
	aspect = math.max(aspect, 0.5)
	local verticalFov = math.rad(camera.FieldOfView)
	local horizontalFov = 2 * math.atan(math.tan(verticalFov * 0.5) * aspect)
	local verticalDistance = size.Y * 0.5 / math.tan(verticalFov * 0.5)
	local horizontalDistance = size.X * 0.5 / math.tan(horizontalFov * 0.5)
	local distance = math.max(verticalDistance, horizontalDistance, 4) + size.Z * 0.65
	local focus = cf.Position + Vector3.new(0, size.Y * 0.03, 0)
	camera.CFrame = CFrame.new(focus + Vector3.new(0, 0, distance), focus)
end

local function findWearableTemplate(itemKey: string): Accessory?
	local folderName = Theme.WearablesFolder or "SoftPhoneWearables"
	local folder = ReplicatedStorage:FindFirstChild(folderName)
	if not folder then
		return nil
	end

	local candidate = folder:FindFirstChild(itemKey)
	if not candidate then
		return nil
	end
	if candidate:IsA("Accessory") then
		return candidate
	end
	return candidate:FindFirstChildWhichIsA("Accessory", true)
end

local function applyExactTryOn(model: Model, item): boolean
	local template = findWearableTemplate(item.Key)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not template or not humanoid then
		return false
	end

	local accessory = template:Clone()
	stripScripts(accessory)
	local ok, message = pcall(function()
		humanoid:AddAccessory(accessory)
	end)
	if not ok then
		accessory:Destroy()
		warn("[SoftPhoneUI] Could not preview wearable " .. item.Key .. ": " .. tostring(message))
		return false
	end
	return true
end

local function bodyPart(model: Model, names: { string }): BasePart?
	for _, name in ipairs(names) do
		local part = model:FindFirstChild(name)
		if part and part:IsA("BasePart") then
			return part
		end
	end
	return nil
end

local function wearablePart(model: Model, name: string, target: BasePart, size: Vector3, offset: CFrame, color: Color3, shape: Enum.PartType?)
	local part = Instance.new("Part")
	part.Name = "PreviewWearable_" .. name
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.CastShadow = false
	part.Material = Enum.Material.SmoothPlastic
	part.Color = color
	part.Size = size
	part.Shape = shape or Enum.PartType.Block
	part.CFrame = target.CFrame * offset
	part.Parent = model
	return part
end

local function applySampleTryOn(model: Model, item)
	local upper = bodyPart(model, { "UpperTorso", "Torso" })
	local lower = bodyPart(model, { "LowerTorso", "Torso" })
	local head = bodyPart(model, { "Head" })
	local leftArm = bodyPart(model, { "LeftUpperArm", "Left Arm" })
	local rightArm = bodyPart(model, { "RightUpperArm", "Right Arm" })
	local leftFoot = bodyPart(model, { "LeftFoot", "Left Leg" })
	local rightFoot = bodyPart(model, { "RightFoot", "Right Leg" })

	if item.Key == "pixel_bow_jacket" and upper then
		wearablePart(model, "Jacket", upper, Vector3.new(upper.Size.X * 1.05, upper.Size.Y * 0.9, upper.Size.Z * 1.08), CFrame.new(0, 0.05, 0), item.Color)
		local front = -(upper.Size.Z * 0.57)
		wearablePart(model, "BowLeft", upper, Vector3.new(0.46, 0.27, 0.14), CFrame.new(-0.22, upper.Size.Y * 0.25, front) * CFrame.Angles(0, 0, math.rad(22)), Theme.Colors.AccentPinkDeep)
		wearablePart(model, "BowRight", upper, Vector3.new(0.46, 0.27, 0.14), CFrame.new(0.22, upper.Size.Y * 0.25, front) * CFrame.Angles(0, 0, math.rad(-22)), Theme.Colors.AccentPinkDeep)
		wearablePart(model, "BowGem", upper, Vector3.new(0.2, 0.2, 0.2), CFrame.new(0, upper.Size.Y * 0.25, front - 0.08), Theme.Colors.Gem, Enum.PartType.Ball)
	elseif item.Key == "starline_skirt" and lower then
		wearablePart(model, "SkirtTop", lower, Vector3.new(lower.Size.X * 1.32, 0.46, lower.Size.Z * 1.3), CFrame.new(0, -lower.Size.Y * 0.38, 0), item.Color)
		wearablePart(model, "SkirtHem", lower, Vector3.new(lower.Size.X * 1.58, 0.25, lower.Size.Z * 1.5), CFrame.new(0, -lower.Size.Y * 0.7, 0), Theme.Colors.AccentLavender)
	elseif item.Key == "bubble_boots" then
		for _, pair in ipairs({ { "Left", leftFoot }, { "Right", rightFoot } }) do
			local side = pair[1]
			local foot = pair[2]
			if foot then
				wearablePart(model, "Boot" .. side, foot, Vector3.new(foot.Size.X * 1.28, foot.Size.Y * 1.28, foot.Size.Z * 1.42), CFrame.new(0, -0.05, -0.08), item.Color)
				wearablePart(model, "BootSole" .. side, foot, Vector3.new(foot.Size.X * 1.38, 0.16, foot.Size.Z * 1.55), CFrame.new(0, -foot.Size.Y * 0.62, -0.08), Theme.Colors.AccentBlue)
			end
		end
	elseif item.Key == "ribbon_satchel" and lower then
		local front = -(lower.Size.Z * 0.62)
		wearablePart(model, "Satchel", lower, Vector3.new(0.78, 0.62, 0.24), CFrame.new(0.48, -0.15, front), item.Color)
		wearablePart(model, "SatchelGem", lower, Vector3.new(0.2, 0.2, 0.2), CFrame.new(0.48, -0.15, front - 0.16), Theme.Colors.Gem, Enum.PartType.Ball)
	elseif item.Key == "mint_sleeve_set" then
		for _, pair in ipairs({ { "Left", leftArm }, { "Right", rightArm } }) do
			local side = pair[1]
			local arm = pair[2]
			if arm then
				wearablePart(model, "Sleeve" .. side, arm, Vector3.new(arm.Size.X * 1.22, arm.Size.Y * 0.88, arm.Size.Z * 1.22), CFrame.new(0, -0.06, 0), item.Color)
			end
		end
	elseif item.Key == "glow_hairclip" and head then
		local front = -(head.Size.Z * 0.57)
		wearablePart(model, "ClipLeft", head, Vector3.new(0.3, 0.2, 0.12), CFrame.new(0.38, 0.42, front) * CFrame.Angles(0, 0, math.rad(25)), item.Color)
		wearablePart(model, "ClipRight", head, Vector3.new(0.3, 0.2, 0.12), CFrame.new(0.58, 0.42, front) * CFrame.Angles(0, 0, math.rad(-25)), Theme.Colors.AccentPink)
		wearablePart(model, "ClipGem", head, Vector3.new(0.17, 0.17, 0.17), CFrame.new(0.48, 0.42, front - 0.08), Theme.Colors.Gem, Enum.PartType.Ball)
	end
end

function ShopWindow.mount(parent: Instance, onClose: (() -> ())?)
	local handle = WindowChrome.create(parent, "Shop", "shop", onClose)
	local content = handle.Content
	local footer = handle.Footer

	local toolbar = Instance.new("Frame")
	toolbar.Name = "ShopToolbar"
	toolbar.BackgroundTransparency = 1
	toolbar.Position = UDim2.fromOffset(6, 4)
	toolbar.Size = UDim2.new(0.34, -8, 0, 64)
	toolbar.ZIndex = 44
	toolbar.Parent = content

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "SearchBox"
	searchBox.BackgroundColor3 = Theme.Colors.AccentCream
	searchBox.BorderSizePixel = 0
	searchBox.Size = UDim2.new(1, 0, 0, 30)
	searchBox.ClearTextOnFocus = false
	searchBox.Font = Theme.Fonts.Body
	searchBox.PlaceholderText = "Search items"
	searchBox.PlaceholderColor3 = Theme.Colors.TextMuted
	searchBox.Text = ""
	searchBox.TextColor3 = Theme.Colors.TextPrimary
	searchBox.TextSize = 11
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.ZIndex = 45
	searchBox.Parent = toolbar
	corner(searchBox, 8)
	stroke(searchBox, Theme.Colors.ButtonStroke, 1, 0.35)
	local searchPadding = Instance.new("UIPadding")
	searchPadding.PaddingLeft = UDim.new(0, 10)
	searchPadding.PaddingRight = UDim.new(0, 32)
	searchPadding.Parent = searchBox

	local clearSearch = Instance.new("TextButton")
	clearSearch.Name = "ClearSearch"
	clearSearch.AnchorPoint = Vector2.new(1, 0.5)
	clearSearch.Position = UDim2.new(1, -5, 0, 15)
	clearSearch.Size = UDim2.fromOffset(22, 22)
	clearSearch.BackgroundColor3 = Theme.Colors.ButtonFill
	clearSearch.BorderSizePixel = 0
	clearSearch.AutoButtonColor = false
	clearSearch.Font = Theme.Fonts.Title
	clearSearch.Text = "X"
	clearSearch.TextColor3 = Theme.Colors.AccentPinkDeep
	clearSearch.TextSize = 9
	clearSearch.Visible = false
	clearSearch.ZIndex = 47
	clearSearch.Parent = toolbar
	corner(clearSearch, 7)
	clearSearch.Activated:Connect(function()
		searchBox.Text = ""
		searchBox:ReleaseFocus()
	end)

	local categoryBar = Instance.new("Frame")
	categoryBar.Name = "CategoryBar"
	categoryBar.BackgroundTransparency = 1
	categoryBar.Position = UDim2.fromOffset(0, 36)
	categoryBar.Size = UDim2.new(1, 0, 0, 26)
	categoryBar.ZIndex = 44
	categoryBar.Parent = toolbar

	local categoryLayout = Instance.new("UIListLayout")
	categoryLayout.FillDirection = Enum.FillDirection.Horizontal
	categoryLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	categoryLayout.Padding = UDim.new(0, 4)
	categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	categoryLayout.Parent = categoryBar

	local categoryButtons = {}
	for index, category in ipairs({ "ALL", "CLOTHES", "ACCESSORIES" }) do
		local button = Instance.new("TextButton")
		button.Name = category .. "Filter"
		button.AutoButtonColor = false
		button.BackgroundColor3 = index == 1 and Theme.Colors.ButtonFillHover or Theme.Colors.AccentCream
		button.BorderSizePixel = 0
		button.Size = UDim2.new(0.32, -2, 1, 0)
		button.LayoutOrder = index
		button.Font = Theme.Fonts.Title
		button.Text = category == "ACCESSORIES" and "ACCESS." or category
		button.TextColor3 = index == 1 and Theme.Colors.TextPrimary or Theme.Colors.AccentPinkDeep
		button.TextSize = 8
		button.ZIndex = 45
		button.Parent = categoryBar
		corner(button, 7)
		local buttonStroke = stroke(button, Theme.Colors.ButtonStroke, index == 1 and 1.5 or 1, index == 1 and 0.05 or 0.42)
		categoryButtons[category] = { Button = button, Stroke = buttonStroke }
	end

	local itemGrid = Instance.new("ScrollingFrame")
	itemGrid.Name = "ItemGrid"
	itemGrid.BackgroundColor3 = Color3.fromRGB(255, 247, 253)
	itemGrid.BackgroundTransparency = 0
	itemGrid.BorderSizePixel = 0
	itemGrid.Size = UDim2.new(0.34, -8, 1, -76)
	itemGrid.Position = UDim2.fromOffset(6, 72)
	itemGrid.ScrollBarThickness = 4
	itemGrid.ScrollBarImageColor3 = Theme.Colors.Scrollbar
	itemGrid.CanvasSize = UDim2.fromOffset(0, 0)
	itemGrid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	itemGrid.ZIndex = 43
	itemGrid.Parent = content

	local gridCorner = Instance.new("UICorner")
	gridCorner.CornerRadius = UDim.new(0, 10)
	gridCorner.Parent = itemGrid

	local gridStroke = Instance.new("UIStroke")
	gridStroke.Color = Theme.Colors.AccentPink
	gridStroke.Thickness = 1
	gridStroke.Transparency = 0.55
	gridStroke.Parent = itemGrid

	local gridPad = Instance.new("UIPadding")
	gridPad.PaddingTop = UDim.new(0, 8)
	gridPad.PaddingLeft = UDim.new(0, 8)
	gridPad.PaddingRight = UDim.new(0, 8)
	gridPad.PaddingBottom = UDim.new(0, 8)
	gridPad.Parent = itemGrid

	local gridLayout = Instance.new("UIListLayout")
	gridLayout.Padding = UDim.new(0, 8)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = itemGrid

	local emptyLabel = Instance.new("TextLabel")
	emptyLabel.Name = "EmptyResults"
	emptyLabel.BackgroundTransparency = 1
	emptyLabel.Size = UDim2.new(1, -4, 0, 56)
	emptyLabel.LayoutOrder = 100
	emptyLabel.Font = Theme.Fonts.Body
	emptyLabel.Text = "No matching items"
	emptyLabel.TextColor3 = Theme.Colors.TextMuted
	emptyLabel.TextSize = 11
	emptyLabel.Visible = false
	emptyLabel.ZIndex = 44
	emptyLabel.Parent = itemGrid

	local stage = Instance.new("Frame")
	stage.Name = "TryOnStage"
	stage.BackgroundColor3 = Theme.Colors.PanelFill
	stage.BorderSizePixel = 0
	stage.Position = UDim2.new(0.35, 0, 0, 4)
	stage.Size = UDim2.new(0.38, 0, 1, -8)
	stage.ZIndex = 43
	stage.Parent = content

	local stageCorner = Instance.new("UICorner")
	stageCorner.CornerRadius = UDim.new(0, 8)
	stageCorner.Parent = stage

	local stageGrad = Instance.new("UIGradient")
	stageGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Theme.Colors.PanelFill),
		ColorSequenceKeypoint.new(0.55, Theme.Colors.PanelFillAlt),
		ColorSequenceKeypoint.new(1, Theme.Colors.SlotBgAlt),
	})
	stageGrad.Rotation = 90
	stageGrad.Parent = stage

	local stageRing = Instance.new("Frame")
	stageRing.Name = "StageRing"
	stageRing.AnchorPoint = Vector2.new(0.5, 1)
	stageRing.Position = UDim2.new(0.5, 0, 1, -38)
	stageRing.Size = UDim2.new(0.72, 0, 0, 20)
	stageRing.BackgroundColor3 = Theme.Colors.AccentPink
	stageRing.BackgroundTransparency = 0.62
	stageRing.BorderSizePixel = 0
	stageRing.ZIndex = 43
	stageRing.Parent = stage
	corner(stageRing, 999)
	stroke(stageRing, Theme.Colors.AccentLavender, 1, 0.42)

	local previewStatus = Instance.new("Frame")
	previewStatus.Name = "PreviewStatus"
	previewStatus.BackgroundColor3 = Theme.Colors.ButtonFill
	previewStatus.BorderSizePixel = 0
	previewStatus.AnchorPoint = Vector2.new(0.5, 0)
	previewStatus.Position = UDim2.new(0.5, 0, 0, 10)
	previewStatus.Size = UDim2.fromOffset(118, 24)
	previewStatus.ZIndex = 46
	previewStatus.Parent = stage
	corner(previewStatus, 12)
	stroke(previewStatus, Theme.Colors.ButtonStroke, 1, 0.22)

	local previewStatusText = Instance.new("TextLabel")
	previewStatusText.Name = "Text"
	previewStatusText.BackgroundTransparency = 1
	previewStatusText.Size = UDim2.fromScale(1, 1)
	previewStatusText.Font = Theme.Fonts.Title
	previewStatusText.TextSize = 10
	previewStatusText.TextColor3 = Theme.Colors.AccentPinkDeep
	previewStatusText.Text = "PREVIEW MODE"
	previewStatusText.ZIndex = 47
	previewStatusText.Parent = previewStatus

	local viewport = Instance.new("ViewportFrame")
	viewport.Name = "AvatarViewport"
	viewport.BackgroundTransparency = 1
	viewport.Size = UDim2.new(1, -12, 1, -72)
	viewport.Position = UDim2.fromOffset(6, 34)
	viewport.Ambient = Color3.fromRGB(255, 220, 244)
	viewport.LightColor = Color3.fromRGB(255, 255, 255)
	viewport.LightDirection = Vector3.new(-0.5, -1, -0.25)
	viewport.ZIndex = 44
	viewport.Parent = stage

	local world = Instance.new("WorldModel")
	world.Name = "World"
	world.Parent = viewport

	local caption = Instance.new("TextLabel")
	caption.Name = "TryOnCaption"
	caption.BackgroundTransparency = 1
	caption.AnchorPoint = Vector2.new(0.5, 1)
	caption.Position = UDim2.new(0.5, 0, 1, -8)
	caption.Size = UDim2.new(0.92, 0, 0, 28)
	caption.Font = Theme.Fonts.Body
	caption.TextSize = 13
	caption.TextWrapped = true
	caption.TextColor3 = Theme.Colors.TextMuted
	caption.Text = "Your look - pick an item"
	caption.ZIndex = 45
	caption.Parent = stage

	local detail = Instance.new("Frame")
	detail.Name = "SelectedItemPanel"
	detail.BackgroundColor3 = Theme.Colors.AccentCream
	detail.BorderSizePixel = 0
	detail.Position = UDim2.new(0.74, 0, 0, 4)
	detail.Size = UDim2.new(0.26, -6, 1, -8)
	detail.ZIndex = 43
	detail.Parent = content

	local detailCorner = Instance.new("UICorner")
	detailCorner.CornerRadius = UDim.new(0, 8)
	detailCorner.Parent = detail

	local detailStroke = Instance.new("UIStroke")
	detailStroke.Color = Theme.Colors.AccentPink
	detailStroke.Thickness = 1.5
	detailStroke.Transparency = 0.25
	detailStroke.Parent = detail

	local detailArt = Instance.new("Frame")
	detailArt.Name = "SelectedArt"
	detailArt.BackgroundColor3 = Color3.fromRGB(255, 244, 252)
	detailArt.BorderSizePixel = 0
	detailArt.Position = UDim2.fromOffset(10, 10)
	detailArt.Size = UDim2.new(1, -20, 0, 112)
	detailArt.ClipsDescendants = true
	detailArt.ZIndex = 44
	detailArt.Parent = detail
	corner(detailArt, 9)
	stroke(detailArt, Theme.Colors.AccentPink, 1, 0.4)

	local detailTitle = Instance.new("TextLabel")
	detailTitle.Name = "SelectedName"
	detailTitle.BackgroundTransparency = 1
	detailTitle.Position = UDim2.fromOffset(12, 132)
	detailTitle.Size = UDim2.new(1, -24, 0, 42)
	detailTitle.Font = Theme.Fonts.Title
	detailTitle.TextSize = 18
	detailTitle.TextWrapped = true
	detailTitle.TextXAlignment = Enum.TextXAlignment.Left
	detailTitle.TextColor3 = Theme.Colors.TextPrimary
	detailTitle.Text = "Select an item"
	detailTitle.ZIndex = 44
	detailTitle.Parent = detail

	local detailPrice = Instance.new("TextLabel")
	detailPrice.Name = "SelectedPrice"
	detailPrice.BackgroundTransparency = 1
	detailPrice.Position = UDim2.fromOffset(12, 176)
	detailPrice.Size = UDim2.new(1, -24, 0, 28)
	detailPrice.Font = Theme.Fonts.Title
	detailPrice.TextSize = 16
	detailPrice.TextXAlignment = Enum.TextXAlignment.Left
	detailPrice.TextColor3 = Theme.Colors.AccentPinkDeep
	detailPrice.Text = "GEMS --"
	detailPrice.ZIndex = 44
	detailPrice.Parent = detail

	local detailNote = Instance.new("TextLabel")
	detailNote.Name = "SelectedNote"
	detailNote.BackgroundTransparency = 1
	detailNote.Position = UDim2.fromOffset(12, 214)
	detailNote.Size = UDim2.new(1, -24, 1, -226)
	detailNote.Font = Theme.Fonts.Body
	detailNote.TextSize = 13
	detailNote.TextWrapped = true
	detailNote.TextXAlignment = Enum.TextXAlignment.Left
	detailNote.TextYAlignment = Enum.TextYAlignment.Top
	detailNote.TextColor3 = Theme.Colors.TextMuted
	detailNote.Text = "Fresh arrivals from Furu Boutique."
	detailNote.ZIndex = 44
	detailNote.Parent = detail

	local selectedItem = nil
	local slotStates = {}
	local previewAngle = 0

	local function refreshAvatar()
		clearViewport(world)
		local player = Players.LocalPlayer
		local character = player.Character
		if not character then
			caption.Text = "Waiting for avatar..."
			return
		end

		local hum = character:FindFirstChildOfClass("Humanoid")
		if not hum then
			caption.Text = "Waiting for humanoid..."
			return
		end

		local originalArchivable = character.Archivable
		character.Archivable = true
		local cloneOk, cloneOrError = pcall(function()
			return character:Clone()
		end)
		character.Archivable = originalArchivable
		if not cloneOk or not cloneOrError then
			caption.Text = "Avatar preview unavailable"
			if not cloneOk then
				warn("[SoftPhoneUI] Could not clone avatar preview:", cloneOrError)
			end
			return
		end
		local clone = cloneOrError :: Model

		stripScripts(clone)
		clone.Name = "PreviewAvatar"
		clone.Parent = world
		local exactTryOn = false
		local sampleTryOn = false
		if selectedItem then
			exactTryOn = applyExactTryOn(clone, selectedItem)
			if not exactTryOn and Theme.EnableSample3DTryOn then
				applySampleTryOn(clone, selectedItem)
				sampleTryOn = true
			end
		end

		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
		if previewAngle ~= 0 then
			clone:PivotTo(clone:GetPivot() * CFrame.Angles(0, math.rad(previewAngle), 0))
		end

		setupCamera(viewport, clone)
		if exactTryOn then
			previewStatusText.Text = "3D TRY-ON"
			caption.Text = "Trying: " .. selectedItem.Name
			detailNote.Text = selectedItem.Tag .. " ITEM\n\n" .. selectedItem.Description
		elseif sampleTryOn then
			previewStatusText.Text = "SAMPLE TRY-ON"
			caption.Text = "Sample: " .. selectedItem.Name
			detailNote.Text = selectedItem.Tag .. " ITEM\n\n" .. selectedItem.Description
		elseif selectedItem then
			previewStatusText.Text = "2D PREVIEW"
			caption.Text = "Selected: " .. selectedItem.Name
			detailNote.Text = selectedItem.Tag .. " ITEM\n\n" .. selectedItem.Description
		else
			previewStatusText.Text = "PREVIEW MODE"
			caption.Text = "Your look - pick an item"
		end
	end

	viewport:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local preview = world:FindFirstChild("PreviewAvatar")
		if preview and preview:IsA("Model") then
			setupCamera(viewport, preview)
		end
	end)

	local activeCategory = "ALL"
	local function updateFilters()
		local query = string.lower(searchBox.Text)
		clearSearch.Visible = query ~= ""
		local visibleCount = 0
		for _, state in ipairs(slotStates) do
			local searchable = string.lower(state.Item.Name .. " " .. state.Item.Tag .. " " .. state.Item.Category .. " " .. state.Item.Description)
			local matchesSearch = query == "" or string.find(searchable, query, 1, true) ~= nil
			local matchesCategory = activeCategory == "ALL" or state.Item.Category == activeCategory
			state.Button.Visible = matchesSearch and matchesCategory
			if state.Button.Visible then
				visibleCount += 1
			end
		end
		emptyLabel.Visible = visibleCount == 0

		for category, state in pairs(categoryButtons) do
			local active = category == activeCategory
			state.Button.BackgroundColor3 = active and Theme.Colors.ButtonFillHover or Theme.Colors.AccentCream
			state.Button.TextColor3 = active and Theme.Colors.TextPrimary or Theme.Colors.AccentPinkDeep
			state.Stroke.Thickness = active and 1.5 or 1
			state.Stroke.Transparency = active and 0.05 or 0.42
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(updateFilters)
	for category, state in pairs(categoryButtons) do
		local selectedCategory = category
		state.Button.Activated:Connect(function()
			activeCategory = selectedCategory
			updateFilters()
		end)
	end

	local function selectItem(item)
		selectedItem = item
		caption.Text = "Selected: " .. item.Name
		previewStatusText.Text = "LOADING PREVIEW"
		detailTitle.Text = item.Name
		detailPrice.Text = "GEMS " .. tostring(item.Price)
		detailNote.Text = item.Tag .. " ITEM\n\n" .. item.Description
		renderItemArt(detailArt, item)

		for _, state in ipairs(slotStates) do
			local selected = state.Item == item
			state.Button.BackgroundColor3 = selected and Color3.fromRGB(255, 232, 246) or Theme.Colors.AccentCream
			state.Stroke.Color = selected and Theme.Colors.AccentPinkDeep or Theme.Colors.AccentPink
			state.Stroke.Thickness = selected and 2.25 or 1.5
			state.Stroke.Transparency = selected and 0 or 0.4
			state.Tag.BackgroundColor3 = selected and Theme.Colors.ButtonFillHover or Color3.fromRGB(255, 231, 247)
			state.SelectedBadge.Visible = selected
		end
		task.defer(refreshAvatar)
	end

	for i, item in ipairs(SAMPLE_ITEMS) do
		local slot = Instance.new("TextButton")
		slot.Name = "Item_" .. i
		slot.AutoButtonColor = true
		slot.BackgroundColor3 = Theme.Colors.AccentCream
		slot.BorderSizePixel = 0
		slot.Size = UDim2.new(1, -4, 0, 96)
		slot.Text = ""
		slot.LayoutOrder = i
		slot.ZIndex = 44
		slot.Parent = itemGrid

		local sc = Instance.new("UICorner")
		sc.CornerRadius = UDim.new(0, 10)
		sc.Parent = slot

		local ss = Instance.new("UIStroke")
		ss.Color = Theme.Colors.AccentPink
		ss.Thickness = 1.5
		ss.Transparency = 0.4
		ss.Parent = slot

		local preview = Instance.new("Frame")
		preview.Name = "ItemSwatch"
		preview.BackgroundColor3 = Color3.fromRGB(255, 244, 252)
		preview.BorderSizePixel = 0
		preview.Size = UDim2.fromOffset(78, 78)
		preview.Position = UDim2.fromOffset(8, 9)
		preview.ClipsDescendants = true
		preview.ZIndex = 45
		preview.Parent = slot

		local pc = Instance.new("UICorner")
		pc.CornerRadius = UDim.new(0, 9)
		pc.Parent = preview
		renderItemArt(preview, item)

		local name = Instance.new("TextLabel")
		name.BackgroundTransparency = 1
		name.Position = UDim2.fromOffset(96, 12)
		name.Size = UDim2.new(1, -104, 0, 34)
		name.Font = Theme.Fonts.Body
		name.TextSize = 12
		name.TextColor3 = Theme.Colors.TextPrimary
		name.Text = item.Name
		name.TextWrapped = true
		name.TextXAlignment = Enum.TextXAlignment.Left
		name.TextYAlignment = Enum.TextYAlignment.Top
		name.ZIndex = 45
		name.Parent = slot

		local price = Instance.new("TextLabel")
		price.BackgroundTransparency = 1
		price.Position = UDim2.fromOffset(96, 49)
		price.Size = UDim2.new(1, -104, 0, 18)
		price.Font = Theme.Fonts.Title
		price.TextSize = 10
		price.TextXAlignment = Enum.TextXAlignment.Left
		price.TextColor3 = Theme.Colors.AccentPinkDeep
		price.Text = "GEMS " .. tostring(item.Price)
		price.ZIndex = 45
		price.Parent = slot

		local tag = Instance.new("TextLabel")
		tag.Name = "Tag"
		tag.BackgroundColor3 = Color3.fromRGB(255, 231, 247)
		tag.BorderSizePixel = 0
		tag.Position = UDim2.fromOffset(96, 70)
		tag.Size = UDim2.fromOffset(62, 17)
		tag.Font = Theme.Fonts.Title
		tag.TextSize = 8
		tag.TextColor3 = Theme.Colors.AccentPinkDeep
		tag.Text = item.Tag
		tag.ZIndex = 45
		tag.Parent = slot
		corner(tag, 8)

		local selectedBadge = Instance.new("TextLabel")
		selectedBadge.Name = "SelectedBadge"
		selectedBadge.BackgroundColor3 = Theme.Colors.AccentPinkDeep
		selectedBadge.BorderSizePixel = 0
		selectedBadge.AnchorPoint = Vector2.new(0.5, 1)
		selectedBadge.Position = UDim2.new(0.5, 0, 1, -6)
		selectedBadge.Size = UDim2.fromOffset(58, 16)
		selectedBadge.Font = Theme.Fonts.Title
		selectedBadge.TextSize = 8
		selectedBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
		selectedBadge.Text = "SELECTED"
		selectedBadge.Visible = false
		selectedBadge.ZIndex = 47
		selectedBadge.Parent = preview
		corner(selectedBadge, 8)

		local compactPrice = Instance.new("TextLabel")
		compactPrice.Name = "CompactPrice"
		compactPrice.AnchorPoint = Vector2.new(1, 0)
		compactPrice.Position = UDim2.new(1, -5, 0, 5)
		compactPrice.Size = UDim2.fromOffset(48, 17)
		compactPrice.BackgroundColor3 = Theme.Colors.AccentCream
		compactPrice.BorderSizePixel = 0
		compactPrice.Font = Theme.Fonts.Title
		compactPrice.Text = tostring(item.Price) .. " G"
		compactPrice.TextColor3 = Theme.Colors.AccentPinkDeep
		compactPrice.TextSize = 8
		compactPrice.Visible = false
		compactPrice.ZIndex = 47
		compactPrice.Parent = preview
		corner(compactPrice, 8)
		stroke(compactPrice, Theme.Colors.ButtonStroke, 1, 0.25)

		table.insert(slotStates, {
			Item = item,
			Button = slot,
			Stroke = ss,
			Tag = tag,
			Name = name,
			Price = price,
			Swatch = preview,
			SelectedBadge = selectedBadge,
			CompactPrice = compactPrice,
		})

		slot.Activated:Connect(function()
			selectItem(item)
		end)
	end
	updateFilters()

	local function updateResponsiveLayout()
		local compact = content.AbsoluteSize.X > 0 and content.AbsoluteSize.X < 520
		detail.Visible = not compact
		if compact then
			toolbar.Size = UDim2.new(0.4, -5, 0, 64)
			itemGrid.Position = UDim2.fromOffset(6, 72)
			itemGrid.Size = UDim2.new(0.4, -5, 1, -76)
			stage.Position = UDim2.new(0.41, 0, 0, 4)
			stage.Size = UDim2.new(0.59, -6, 1, -8)
		else
			toolbar.Size = UDim2.new(0.34, -8, 0, 64)
			itemGrid.Position = UDim2.fromOffset(6, 72)
			itemGrid.Size = UDim2.new(0.34, -8, 1, -76)
			stage.Position = UDim2.new(0.35, 0, 0, 4)
			stage.Size = UDim2.new(0.38, 0, 1, -8)
		end

		for _, state in ipairs(slotStates) do
			state.Name.Visible = not compact
			state.Price.Visible = not compact
			state.Tag.Visible = not compact
			state.CompactPrice.Visible = compact
			state.Swatch.AnchorPoint = compact and Vector2.new(0.5, 0) or Vector2.zero
			state.Swatch.Position = compact and UDim2.new(0.5, 0, 0, 9) or UDim2.fromOffset(8, 9)
		end
	end

	task.defer(updateResponsiveLayout)
	content:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateResponsiveLayout)

	if footer then
		WindowChrome.addFooterButton(footer, "Reset Look", 1, function()
			selectedItem = nil
			previewAngle = 0
			previewStatusText.Text = "PREVIEW MODE"
			detailTitle.Text = "Select an item"
			detailPrice.Text = "GEMS --"
			detailNote.Text = "Fresh arrivals from Furu Boutique."
			for _, state in ipairs(slotStates) do
				state.Button.BackgroundColor3 = Theme.Colors.AccentCream
				state.Stroke.Color = Theme.Colors.AccentPink
				state.Stroke.Thickness = 1.5
				state.Stroke.Transparency = 0.4
				state.Tag.BackgroundColor3 = Color3.fromRGB(255, 231, 247)
				state.SelectedBadge.Visible = false
			end
			for _, child in ipairs(detailArt:GetChildren()) do
				if child:IsA("GuiObject") then
					child:Destroy()
				end
			end
			refreshAvatar()
		end)
		WindowChrome.addFooterButton(footer, "Rotate", 2, function()
			previewAngle = (previewAngle + 35) % 360
			refreshAvatar()
		end)
		WindowChrome.addFooterButton(footer, "Apply Preview", 3, function()
			if selectedItem then
				previewStatusText.Text = "LOADING PREVIEW"
				refreshAvatar()
			else
				caption.Text = "Pick an item first"
				previewStatusText.Text = "PICK ITEM"
			end
		end)
	end

	selectItem(SAMPLE_ITEMS[1])

	local player = Players.LocalPlayer
	if player.Character then
		task.defer(refreshAvatar)
	end
	player.CharacterAdded:Connect(function()
		task.wait(0.35)
		if handle:isOpen() then
			refreshAvatar()
		end
	end)

	local originalSetVisible = handle.setVisible
	function handle:setVisible(visible: boolean, instant: boolean?)
		originalSetVisible(self, visible, instant)
		if visible then
			task.defer(refreshAvatar)
		end
	end

	return handle
end

return ShopWindow
