-- ui.drawCircle() 16 radius = 64 pixel radius = 128 diameter

settings = ac.storage({
	BackgroundColor = rgbm(0, 0, 0, 0.2),
	CustomPos = false,
	positionX = 0,
	positionY = 0,
})

local editing = false

local EditingBG 	= false
local EditingMain 	= false

local colorFlags = bit.bor(ui.ColorPickerFlags.NoSidePreview, ui.ColorPickerFlags.PickerHueWheel)

local function ColorBlock(input)
	input = input or "tempcolor"
	local col = settings[input]:clone()
	ui.colorPicker("##color", col, colorFlags)
	if ui.itemEdited() then
		settings[input] = col
		editing = true
	elseif editing and not ui.itemActive() then
		editing = false
	end
	ui.newLine()
end
--#endregion

function ControllerInputSettings()
	ui.dummy(vec2(256, 2))
	if ui.button(settings.CustomPos == false and "CustomPos Off" or settings.CustomPos == true and "CustomPos On") then
		settings.CustomPos = not settings.CustomPos
	end
	if settings.CustomPos then
		ui.setNextItemWidth(250)
		local X = ui.slider("##X",settings.positionX,0,sim.windowWidth-320,"%.0f",1)
		if X then
			settings.positionX = tonumber(X)
		end
		ui.setNextItemWidth(250)
		local Y = ui.slider("##Y",settings.positionY,0,sim.windowHeight-152,"%.0f",1)
		if Y then
			settings.positionY = tonumber(Y)
		end
	end


	if ui.button("Edit Background") then
			EditingBG = not EditingBG
	end

	if EditingBG then
		ColorBlock("BackgroundColor")
	end
end



local ds5 = {
	Circle		= ac.dirname() .. "\\ds5\\Circle.png",
	Cross		= ac.dirname() .. "\\ds5\\Cross.png",
	Square		= ac.dirname() .. "\\ds5\\Square.png",
	Triangle 	= ac.dirname() .. "\\ds5\\Triangle.png",
}

local StickLut = ac.DataLUT11():add(0, 0):add(1, 64)
StickLut.extrapolate = true

local TriggerStart = math.rad(180)
local TriggerEnd = math.rad(360)
local TriggerLut = ac.DataLUT11():add(0, TriggerStart):add(1, TriggerEnd)
TriggerLut.extrapolate = true

LeftStickMiddle 	= vec2(80, 80)
RightStickMiddle 	= vec2(240, 80)

local FacebuttonSpace = 37
local MainColor = rgbm(1,1,1,0.8)
local SecondColor = rgbm(1,1,1,0.25)


function Controller()
	ui.drawRectFilled(0, AppSize, settings.BackgroundColor, 5, nil)

	--#region [[FaceButtons]]
	--right
	ui.setCursor(RightStickMiddle - 32 + vec2(FacebuttonSpace, 0))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.B) then
		ui.image(ds5.Circle, 64, MainColor)
	else
		ui.image(ds5.Circle, 64, SecondColor)
	end
	--bottom
	ui.setCursor(RightStickMiddle - 32 + vec2(0, FacebuttonSpace))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.A) then
		ui.image(ds5.Cross, 64, MainColor)
	else
		ui.image(ds5.Cross, 64, SecondColor)
	end
	--left
	ui.setCursor(RightStickMiddle - 32 + vec2(-FacebuttonSpace, 0))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.X) then
		ui.image(ds5.Square, 64, MainColor)
	else
		ui.image(ds5.Square, 64, SecondColor)
	end
	--top
	ui.setCursor(RightStickMiddle - 32 + vec2(0, -FacebuttonSpace))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.Y) then
		ui.image(ds5.Triangle, 64, MainColor)
	else
		ui.image(ds5.Triangle, 64, SecondColor)
	end
	--#endregion

	--#region [[Middle of Sticks]]
	ui.drawLine(LeftStickMiddle - vec2(64, 0), LeftStickMiddle + vec2(64, 0), rgbm(1, 1, 1, 0.1), 1)
	ui.drawLine(LeftStickMiddle - vec2(0, 64), LeftStickMiddle + vec2(0, 64), rgbm(1, 1, 1, 0.1), 1)
	ui.drawLine(RightStickMiddle - vec2(64, 0), RightStickMiddle + vec2(64, 0), rgbm(1, 1, 1, 0.1), 1)
	ui.drawLine(RightStickMiddle - vec2(0, 64), RightStickMiddle + vec2(0, 64), rgbm(1, 1, 1, 0.1), 1)
	--#endregion

	--#region [[Axis]]
	--left trigger
	ui.pathArcTo(LeftStickMiddle, 72, TriggerStart, TriggerEnd, 32)
	ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 5)
	ui.pathArcTo(LeftStickMiddle, 72, TriggerStart, LT, 32)
	ui.pathStroke(rgbm(1, 0, 0, 0.8), false, 5)
	--right trigger
	ui.pathArcTo(RightStickMiddle, 72, TriggerStart, TriggerEnd, 32)
	ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 5)
	ui.pathArcTo(RightStickMiddle, 72, TriggerStart, RT, 32)
	ui.pathStroke(rgbm(0, 1, 0, 0.8), false, 5)
	-- LeftStick
	ui.drawCircle(LeftStickMiddle, 64, MainColor, 32, 2)
	ui.drawCircleFilled(LeftStickMiddle + vec2(LSX, LSY), 22, MainColor, 24)
	ui.drawCircleFilled(LeftStickMiddle + vec2(RealSteering, 0), 4, rgbm(1, 0, 0, 0.8), 24)

	--RightStick
	ui.drawCircleFilled(RightStickMiddle + vec2(RSX, RSY), 22, MainColor, 24)
	ui.drawCircle(RightStickMiddle, 64, MainColor, 32, 2)
	--#endregion
end

sim = ac.getSim()
car = ac.getCar(0)
GameSize = vec2(sim.windowWidth, sim.windowHeight)

function ControllerInput()
	--#region [[App Size]]
	AppPos = ui.windowPos()
	AppSize = ui.windowSize()
	--#endregion
	
	--pos stuff
	--leftstick
	LSX = ac.getGamepadAxisValue(4, ac.GamepadAxis.LeftThumbX)
	LSY = ac.getGamepadAxisValue(4, ac.GamepadAxis.LeftThumbY)
	LSX = StickLut:get(LSX)	 * 0.95
	LSY = StickLut:get(-LSY) * 0.95
	--real steer
	RealSteering = car.steer/car.steerLock
	RealSteering = StickLut:get(RealSteering)
	--rightstick
	RSX = ac.getGamepadAxisValue(4, ac.GamepadAxis.RightThumbX)
	RSY = ac.getGamepadAxisValue(4, ac.GamepadAxis.RightThumbY)
	RSX = StickLut:get(RSX)  * 0.95
	RSY = StickLut:get(-RSY) * 0.95
	--triggers
	LT = ac.getGamepadAxisValue(4, ac.GamepadAxis.LeftTrigger)
	RT = ac.getGamepadAxisValue(4, ac.GamepadAxis.RightTrigger)
	LT = TriggerLut:get(LT)
	RT = TriggerLut:get(RT)

	if EditingBG == true and settings.CustomPos == false then
		AppPos = AppPos + vec2(0,AppSize.y)
	elseif EditingBG == true or EditingBG == false and settings.CustomPos == true then
		AppPos = vec2(settings.positionX,settings.positionY)
	end
	ui.transparentWindow("##ATransparentWindow", AppPos, AppSize,Controller)
end
