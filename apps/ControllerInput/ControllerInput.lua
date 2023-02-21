-- ui.drawCircle() 16 radius = 64 pixel radius = 128 diameter

settings = ac.storage({
	Color = rgbm(0, 0, 0, 0.2),
	CustomPos = false,
	positionX = 0,
	positionY = 0,
})




local ds5 = {
	Circle		= ac.dirname() .. "\\ds5\\Circle.png",
	Cross		= ac.dirname() .. "\\ds5\\Cross.png",
	Square		= ac.dirname() .. "\\ds5\\Square.png",
	Triangle 	= ac.dirname() .. "\\ds5\\Triangle.png",
}

local editing = false
local trueedit = false
local colorFlags = bit.bor(ui.ColorPickerFlags.NoSidePreview, ui.ColorPickerFlags.PickerHueWheel)

local function ColorBlock(input)
	input = input or "Color"
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
		if trueedit ~= true then
			trueedit = true
		else
			trueedit = false
		end
	end
	if trueedit then
		ColorBlock(Color)
	end



end

local StickLut = ac.DataLUT11():add(0, 0):add(1, 64)
StickLut.extrapolate = true

local TriggerLut = ac.DataLUT11():add(0, 3):add(1, 6.43)
TriggerLut.extrapolate = true


function Controller()
	ui.drawRectFilled(0, AppSize, settings.Color, 5, nil)
	--#region [[FaceButtons]]
	ui.setCursor(RightStickMiddle-32+vec2(32,0))
	if ac.isGamepadButtonPressed(4,ac.GamepadButton.B) then
		ui.image(ds5.Circle, 64, rgbm(1,1,1,1), nil, nil, nil, nil)
	else
		ui.image(ds5.Circle, 64, rgbm(1,1,1,0.25), nil, nil, nil, nil)
	end
	ui.setCursor(RightStickMiddle-32+vec2(0,32))
	if ac.isGamepadButtonPressed(4,ac.GamepadButton.A) then
		ui.image(ds5.Cross, 64, rgbm(1,1,1,1), nil, nil, nil, nil)
	else
		ui.image(ds5.Cross, 64, rgbm(1,1,1,0.25), nil, nil, nil, nil)
	end
	ui.setCursor(RightStickMiddle-32+vec2(-32,0))
	if ac.isGamepadButtonPressed(4,ac.GamepadButton.X) then
		ui.image(ds5.Square, 64, rgbm(1,1,1,1), nil, nil, nil, nil)
	else
		ui.image(ds5.Square, 64, rgbm(1,1,1,0.25), nil, nil, nil, nil)
	end
	ui.setCursor(RightStickMiddle-32+vec2(0,-32))
	if ac.isGamepadButtonPressed(4,ac.GamepadButton.Y) then
		ui.image(ds5.Triangle, 64, rgbm(1,1,1,1), nil, nil, nil, nil)
	else
		ui.image(ds5.Triangle, 64, rgbm(1,1,1,0.25), nil, nil, nil, nil)
	end
	--#endregion

	--#region [[Middle of Sticks]]
	ui.drawLine(LeftStickMiddle-vec2(64,0),LeftStickMiddle+vec2(64,0),rgbm(1,1,1,0.2),1)
	ui.drawLine(LeftStickMiddle-vec2(0,64),LeftStickMiddle+vec2(0,64),rgbm(1,1,1,0.2),1)
	ui.drawLine(RightStickMiddle-vec2(64,0),RightStickMiddle+vec2(64,0),rgbm(1,1,1,0.2),1)
	ui.drawLine(RightStickMiddle-vec2(0,64),RightStickMiddle+vec2(0,64),rgbm(1,1,1,0.2),1)
	--#endregion

	--#region [[Axis]]
	--left trigger
	ui.pathArcTo(LeftStickMiddle, 75, 3, 6.43, 32)
	ui.pathStroke(rgbm.colors.white, false, 5)
	ui.pathArcTo(LeftStickMiddle, 75, 3, LT, 32)
	ui.pathStroke(rgbm(1,0,0,1), false, 5)
	--right trigger
	ui.pathArcTo(RightStickMiddle, 75, 3, 6.43, 32)
	ui.pathStroke(rgbm.colors.white, false, 5)
	ui.pathArcTo(RightStickMiddle, 75, 3, RT, 32)
	ui.pathStroke(rgbm(0,1,0,1), false, 5)
	-- LeftStick
	ui.drawCircle(LeftStickMiddle, 64, rgbm(1, 1, 1, 1), 32, 2)
	ui.drawCircle(LeftStickMiddle + vec2(RealSteering, 0), 4, rgbm(1, 0, 0, 1), 8, 2)
	ui.drawCircle(LeftStickMiddle + vec2(LSX, LSY), 22, rgbm(1, 1, 1, 1), 24, 2)
	ui.drawCircle(LeftStickMiddle + vec2(LSX, LSY), 2, rgbm(1, 1, 1, 1), 4, 2)

	--RightStick
	ui.drawCircle(RightStickMiddle + vec2(RSX, RSY), 22, rgbm(1, 1, 1, 1), 24, 2)
	ui.drawCircle(RightStickMiddle + vec2(RSX, RSY), 2, rgbm(1, 1, 1, 1), 4, 2)
	ui.drawCircle(RightStickMiddle, 64, rgbm(1, 1, 1, 1), 32, 2)
	--#endregion
end

function ControllerInput()
	sim = ac.getSim()
	car = ac.getCar(0)
	GameSize = vec2(sim.windowWidth, sim.windowHeight)
	--#region [[App Size]]
	AppPos = ui.windowPos()
	AppSize = ui.windowSize()
	--#endregion
	
	--pos stuff
	LeftStickMiddle 	= vec2(80, 86)
	RightStickMiddle 	= vec2(240, 86)


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

	if trueedit == true and settings.CustomPos == false then
		AppPos = AppPos + vec2(0,AppSize.y)
	elseif trueedit == false and settings.CustomPos == true then
		AppPos = vec2(settings.positionX,settings.positionY)
	elseif trueedit == true and settings.CustomPos == true then
		AppPos = vec2(settings.positionX,settings.positionY)
	end
	ui.transparentWindow("##ATransparentWindow", AppPos, AppSize,Controller)
end
