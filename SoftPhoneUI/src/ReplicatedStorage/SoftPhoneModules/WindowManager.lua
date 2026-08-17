--[[
	Central toggle: one feature window open at a time; slide dismiss matches open.
]]

local WindowManager = {}
WindowManager.__index = WindowManager

local function loadModule(name: string)
	local moduleScript = script.Parent:FindFirstChild(name)
	if not moduleScript or not moduleScript:IsA("ModuleScript") then
		warn("[SoftPhoneUI] Missing module:", name)
		return nil
	end

	local ok, result = pcall(require, moduleScript)
	if not ok then
		warn("[SoftPhoneUI] Could not load " .. name .. ":", result)
		return nil
	end
	return result
end

function WindowManager.new(host: Frame, onActiveChanged: ((string?) -> ())?, onStateChanged: ((string, any) -> ())?, onAction: ((string, string, any?) -> ())?)
	local self = setmetatable({}, WindowManager)
	self._host = host
	self._windows = {}
	self._active = nil :: string?
	self._onActiveChanged = onActiveChanged

	local function closer(id: string)
		return function()
			if self._active == id then
				self._active = nil
				if self._onActiveChanged then
					self._onActiveChanged(nil)
				end
			end
		end
	end

	local ShopWindow = loadModule("ShopWindow")
	if ShopWindow then
		local ok, handle = pcall(ShopWindow.mount, host, closer("Shop"), onAction)
		if ok then
			self._windows.Shop = handle
		else
			warn("[SoftPhoneUI] Could not mount Shop:", handle)
		end
	end

	local PlaceholderWindows = loadModule("PlaceholderWindows")
	if PlaceholderWindows then
		local ok, placeholders = pcall(PlaceholderWindows.mountAll, host, closer, onStateChanged, onAction)
		if ok then
			for id, handle in pairs(placeholders) do
				self._windows[id] = handle
			end
		else
			warn("[SoftPhoneUI] Could not mount feature windows:", placeholders)
		end
	end

	return self
end

function WindowManager:open(id: string)
	local target = self._windows[id]
	if not target then
		warn("[SoftPhoneUI] Unknown window:", id)
		return
	end

	if self._active == id and target:isOpen() then
		return self:hide(id)
	end
	return self:show(id)
end

function WindowManager:show(id: string)
	local target = self._windows[id]
	if not target then
		warn("[SoftPhoneUI] Unknown window:", id)
		return
	end

	if self._active and self._active ~= id then
		local current = self._windows[self._active]
		if current then
			current:setVisible(false, false)
		end
	end

	if not target:isOpen() then
		target:setVisible(true, false)
	end
	self._active = id
	if self._onActiveChanged then
		self._onActiveChanged(self._active)
	end
	return self._active
end

function WindowManager:hide(id: string)
	local target = self._windows[id]
	if not target then
		warn("[SoftPhoneUI] Unknown window:", id)
		return self._active
	end
	if target:isOpen() then
		target:setVisible(false, false)
	end
	if self._active == id then
		self._active = nil
		if self._onActiveChanged then
			self._onActiveChanged(nil)
		end
	end
	return self._active
end

function WindowManager:closeAll(instant: boolean?)
	for _, handle in pairs(self._windows) do
		if handle:isOpen() then
			handle:setVisible(false, instant)
		end
	end
	self._active = nil
	if self._onActiveChanged then
		self._onActiveChanged(nil)
	end
end

function WindowManager:getActive(): string?
	return self._active
end

function WindowManager:isAvailable(id: string): boolean
	return self._windows[id] ~= nil
end

return WindowManager
