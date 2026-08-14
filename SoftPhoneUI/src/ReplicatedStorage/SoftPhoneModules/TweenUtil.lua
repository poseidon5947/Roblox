local TweenService = game:GetService("TweenService")
local Theme = require(script.Parent.Theme)

local TweenUtil = {}

function TweenUtil.play(instance: Instance, props: { [string]: any }, duration: number?, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween
	local info = TweenInfo.new(
		duration or Theme.Tween.SlideTime,
		style or Theme.Tween.SlideStyle,
		direction or Theme.Tween.SlideDir
	)
	local tween = TweenService:Create(instance, info, props)
	tween:Play()
	return tween
end

function TweenUtil.slidePosition(gui: GuiObject, target: UDim2, duration: number?): Tween
	return TweenUtil.play(gui, { Position = target }, duration or Theme.Tween.SlideTime)
end

function TweenUtil.fade(gui: GuiObject, transparency: number, duration: number?): Tween
	return TweenUtil.play(gui, { BackgroundTransparency = transparency }, duration or Theme.Tween.QuickTime, Enum.EasingStyle.Quad)
end

return TweenUtil
