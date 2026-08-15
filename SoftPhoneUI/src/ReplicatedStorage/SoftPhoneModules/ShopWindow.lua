--[[
	Shop window with a centered R15 avatar try-on preview.
	Catalog/apply hooks can replace the sample item callbacks later.
]]

local Players = game:GetService("Players")
local Theme = require(script.Parent.Theme)
local WindowChrome = require(script.Parent.WindowChrome)

local ShopWindow = {}

local SAMPLE_ITEMS = {
	{ Key = "pixel_bow_jacket", Name = "Pixel Bow Jacket", Price = 120, Color = Theme.Colors.AccentPink, Tag = "NEW" },
	{ Key = "starline_skirt", Name = "Starline Skirt", Price = 90, Color = Theme.Colors.AccentLavender, Tag = "RARE" },
	{ Key = "bubble_boots", Name = "Bubble Boots", Price = 150, Color = Theme.Colors.AccentBlue, Tag = "TRENDING" },
	{ Key = "ribbon_satchel", Name = "Ribbon Satchel", Price = 75, Color = Theme.Colors.AccentPinkDeep, Tag = "CUTE" },
	{ Key = "mint_sleeve_set", Name = "Mint Sleeve Set", Price = 40, Color = Theme.Colors.AccentMint, Tag = "SET" },
	{ Key = "glow_hairclip", Name = "Glow Hairclip", Price = 55, Color = Theme.Colors.AccentLavender, Tag = "LIMITED" },
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
	local camera = Instance.new("Camera")
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	local hrp = model:FindFirstChild("HumanoidRootPart") :: BasePart?
	if hrp then
		camera.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 1.5, 6), hrp.Position + Vector3.new(0, 1.2, 0))
	else
		local cf, size = model:GetBoundingBox()
		camera.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.2, size.Magnitude), cf.Position)
	end
end

function ShopWindow.mount(parent: Instance, onClose: (() -> ())?)
	local handle = WindowChrome.create(parent, "Shop", "shop", onClose)
	local content = handle.Content
	local footer = handle.Footer

	local itemGrid = Instance.new("ScrollingFrame")
	itemGrid.Name = "ItemGrid"
	itemGrid.BackgroundColor3 = Color3.fromRGB(255, 247, 253)
	itemGrid.BackgroundTransparency = 0
	itemGrid.BorderSizePixel = 0
	itemGrid.Size = UDim2.new(0.34, -8, 1, -8)
	itemGrid.Position = UDim2.fromOffset(6, 4)
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
	detailNote.Text = "Tap an item to preview it here. Full avatar try-on is ready for catalog asset IDs."
	detailNote.ZIndex = 44
	detailNote.Parent = detail

	local selectedItem = nil
	local slotStates = {}

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

		character.Archivable = true
		local clone = character:Clone()
		character.Archivable = false
		if not clone then
			caption.Text = "Avatar preview unavailable"
			return
		end

		stripScripts(clone)
		clone.Name = "PreviewAvatar"
		clone.Parent = world

		for _, part in ipairs(clone:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end

		setupCamera(viewport, clone)
		caption.Text = selectedItem and ("Trying: " .. selectedItem.Name) or "Your look - pick an item"
	end

	local function selectItem(item)
		selectedItem = item
		caption.Text = "Trying: " .. item.Name
		previewStatusText.Text = string.upper(item.Tag) .. " PREVIEW"
		detailTitle.Text = item.Name
		detailPrice.Text = "GEMS " .. tostring(item.Price)
		detailNote.Text = item.Tag .. " ITEM\n\nSelected for preview. Add catalog IDs to enable live avatar fitting."
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

		table.insert(slotStates, {
			Item = item,
			Button = slot,
			Stroke = ss,
			Tag = tag,
			SelectedBadge = selectedBadge,
		})

		slot.Activated:Connect(function()
			selectItem(item)
		end)
	end

	if footer then
		WindowChrome.addFooterButton(footer, "Reset Look", 1, function()
			selectedItem = nil
			previewStatusText.Text = "PREVIEW MODE"
			detailTitle.Text = "Select an item"
			detailPrice.Text = "GEMS --"
			detailNote.Text = "Tap an item to preview it here. Full avatar try-on is ready for catalog asset IDs."
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
		WindowChrome.addFooterButton(footer, "Refresh", 2, refreshAvatar)
		WindowChrome.addFooterButton(footer, "Apply Preview", 3, function()
			caption.Text = selectedItem and ("Previewing: " .. selectedItem.Name) or "Pick an item first"
			previewStatusText.Text = selectedItem and "LOOK APPLIED" or "PICK ITEM"
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
