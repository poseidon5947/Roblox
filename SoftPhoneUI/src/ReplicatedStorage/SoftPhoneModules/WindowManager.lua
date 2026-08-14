--[[
	Central toggle: one feature window open at a time; slide dismiss matches open.
]]

local ShopWindow = require(script.Parent.ShopWindow)
local PlaceholderWindows = require(script.Parent.PlaceholderWindows)

local WindowManager = {}
WindowManager.__index = WindowManager

function WindowManager.new(host: Frame)
	local self = setmetatable({}, WindowManager)
	self._host = host
	self._windows = {}
	self._active = nil :: string?

	local function closer(id: string)
		return function()
			if self._active == id then
				self._active = nil
			end
		end
	end

	self._windows.Shop = ShopWindow.mount(host, closer("Shop"))
	local placeholders = PlaceholderWindows.mountAll(host, closer)
	for id, handle in pairs(placeholders) do
		self._windows[id] = handle
	end

	return self
end

function WindowManager:open(id: string)
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

	if self._active == id and target:isOpen() then
		target:setVisible(false, false)
		self._active = nil
		return
	end

	target:setVisible(true, false)
	self._active = id
end

function WindowManager:closeAll(instant: boolean?)
	for _, handle in pairs(self._windows) do
		if handle:isOpen() then
			handle:setVisible(false, instant)
		end
	end
	self._active = nil
end

function WindowManager:getActive(): string?
	return self._active
end

return WindowManager
