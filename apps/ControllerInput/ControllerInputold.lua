-- ui.drawCircle() 16 radius = 64 pixel radius = 128 diameter

settings = ac.storage({
	Hidden = false,
	BackgroundColor = rgbm(0, 0, 0, 0.2),
	Controller = "PS",
	CustomPos = false,
	positionX = 0,
	positionY = 0,
})

--#region [MainParts]
local sim = ac.getSim()
local car = ac.getCar(0)
local GameSize = vec2(sim.windowWidth, sim.windowHeight)
local AppSize = vec2(320, 152)
local dualsense = ac.getDualSense(Controller)
local Touch1 = dualsense.touches[0]
local Touch2 = dualsense.touches[1]
--#endregion


--#region [Random Functions]
local function interp(x1,x2,value,y1,y2)
	return math.lerp(y1,y2,math.lerpInvSat(value,x1,x2))
end

LAST_DEBOUNCE = 0
function debounceValues(func, wait)
    local now = sim.time
	ac.debug("now",now)
	ac.debug("now - LAST_DEBOUNCE",now - LAST_DEBOUNCE)
	ac.debug("wait",wait)
    if now - LAST_DEBOUNCE < wait then return end
    LAST_DEBOUNCE = now
    return func()
end
--#endregion


--#region [Color]
local editing = false
local EditingBG 	= false
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
--#region [Settings]
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
--#endregion

--#region [Stick Related]
local StickLut = ac.DataLUT11():add(0, 0):add(1, 64)
StickLut.extrapolate = true

local LeftStickMiddle 	= vec2(80, 80)
local RightStickMiddle 	= vec2(240, 80)
--#endregion

--#region[Color]
local MainColor 	= rgbm(1,1,1,0.8)
local SecondColor 	= rgbm(1,1,1,0.25)
--#endregion

--#region [Triggers]
local TriggerStart = math.rad(180)
local TriggerEnd = math.rad(360)
local TriggerLut = ac.DataLUT11():add(0, TriggerStart):add(1, TriggerEnd)
TriggerLut.extrapolate = true
--#endregion

--#region  [Touch Related]
local TouchingColor1 = rgbm(0, 0.5, 1, 0.5)
local TouchingColor2 = rgbm(0, 1, 0.5, 0.5)

local LightHeadlight	= false
local HighBeamsTouch1	= false
local HighBeamsTouch2	= false
local HazardTouch1		= false
local HazardTouch2		= false
local LightLTurn		= false
local LightRTurn		= false
local LightOff			= false
--#endregion

--#region [Middle thing]
local function Middle()
	ui.drawLine(LeftStickMiddle - vec2(64, 0), LeftStickMiddle + vec2(64, 0), rgbm(1, 1, 1, 0.1), 1)
	ui.drawLine(LeftStickMiddle - vec2(0, 64), LeftStickMiddle + vec2(0, 64), rgbm(1, 1, 1, 0.1), 1)
	ui.drawLine(RightStickMiddle - vec2(64, 0), RightStickMiddle + vec2(64, 0), rgbm(1, 1, 1, 0.1), 1)
	ui.drawLine(RightStickMiddle - vec2(0, 64), RightStickMiddle + vec2(0, 64), rgbm(1, 1, 1, 0.1), 1)
end
--#endregion

--#region [Facebuttons]
local Face_Right = nil
local Face_Down  = nil
local Face_Left  = nil
local Face_Up	 = nil

local FacebuttonGap = 36

Facebuttons = {
	PS = {
		Face_Right = ac.dirname() .. "\\ds5\\Circle.png",
		Face_Down = ac.dirname() .. "\\ds5\\Cross.png",
		Face_Left = ac.dirname() .. "\\ds5\\Square.png",
		Face_Up = ac.dirname() .. "\\ds5\\Triangle.png",
	},
}
F_Face_Right = function()
	ui.setCursor(RightStickMiddle - 32 + vec2(FacebuttonGap, 0))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.B) then
		ui.image(Face_Right, 64, MainColor)
	else
		ui.image(Face_Right, 64, SecondColor)
	end
end
F_Face_Down = function()
	--bottom
	ui.setCursor(RightStickMiddle - 32 + vec2(0, FacebuttonGap))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.A) then
		ui.image(Face_Down, 64, MainColor)
	else
		ui.image(Face_Down, 64, SecondColor)
	end
end
F_Face_Left = function()
	--left
	ui.setCursor(RightStickMiddle - 32 + vec2(-FacebuttonGap, 0))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.X) then
		ui.image(Face_Left, 64, MainColor)
	else
		ui.image(Face_Left, 64, SecondColor)
	end
end
F_Face_Up = function()
	--top
	ui.setCursor(RightStickMiddle - 32 + vec2(0, -FacebuttonGap))
	if ac.isGamepadButtonPressed(4, ac.GamepadButton.Y) then
		ui.image(Face_Up, 64, MainColor)
	else
		ui.image(Face_Up, 64, SecondColor)
	end
end
--#endregion

--#region [Lights]
local Lights = {
	Hazards = function()
		if car.hazardLights == true then
			ac.setTurningLights(ac.TurningLights.None)
		elseif car.hazardLights == false then
			ac.setTurningLights(ac.TurningLights.Hazards)
		end
	end,
	TurnLeft = function()
		if car.turningLeftLights == true then
			ac.setTurningLights(ac.TurningLights.None)
		elseif car.hazardLights == false then
			ac.setTurningLights(ac.TurningLights.Left)
		end
	end,
	TurnRight = function()
		if car.turningRightLights == true then
			ac.setTurningLights(ac.TurningLights.None)
		elseif car.hazardLights == false then
			ac.setTurningLights(ac.TurningLights.Right)
		end
	end,
	Headlights = function()
		if car.headlightsActive == true then
			ac.setHeadlights(false)
		elseif car.headlightsActive == false then
			ac.setHeadlights(true)
		end
	end,
	Highbeams = function()
		if car.lowBeams == true then
			ac.setHighBeams(true)
		elseif car.lowBeams == false then
			ac.setHighBeams(false)
		end
	end,
	Off = function()
		ac.setTurningLights(ac.TurningLights.None)
	end,
}
--#endregion

--#region [Axises]
local function LeftTrigger()
	ui.pathArcTo(LeftStickMiddle, 72, TriggerStart, TriggerEnd, 32)
	ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 5)
	ui.pathArcTo(LeftStickMiddle, 72, TriggerStart, LT, 32)
	ui.pathStroke(rgbm(1, 0, 0, 0.8), false, 5)
end
local function RightTrigger()
	ui.pathArcTo(RightStickMiddle, 72, TriggerStart, TriggerEnd, 32)
	ui.pathStroke(rgbm(1, 1, 1, 0.3), false, 5)
	ui.pathArcTo(RightStickMiddle, 72, TriggerStart, RT, 32)
	ui.pathStroke(rgbm(0, 1, 0, 0.8), false, 5)
end
local function LeftStick()
	ui.drawCircle(LeftStickMiddle, 64, MainColor, 32, 2)
	ui.drawCircleFilled(LeftStickMiddle + vec2(LSX, LSY), 22, MainColor, 24)
	ui.drawCircleFilled(LeftStickMiddle + vec2(RealSteering, 0), 4, rgbm(1, 0, 0, 0.8), 24)

end
local function RightStick()
	ui.drawCircleFilled(RightStickMiddle + vec2(RSX, RSY), 22, MainColor, 24)
	ui.drawCircle(RightStickMiddle, 64, MainColor, 32, 2)
end
--#endregion

local function TouchingStory()
	local PadButton = ac.isGamepadButtonPressed(4, ac.GamepadButton.Pad)
	if Touch1.down then
		Toucher1 = vec2(interp(0, 0.959500, Touch1.pos.x, 0, AppSize.x), interp(0, 0.526855, Touch1.pos.y, 0, AppSize.y))
		TouchingColor1 = rgbm(0, 0.5, 1, 0.5)
		if PadButton then
			TouchingColor1 = rgbm(0, 0.5, 1, 1)
		end

		LightLTurn = (Toucher1.x < AppSize.x * 0.2)
		LightRTurn = (Toucher1.x > AppSize.x * 0.8)
		LightOff = (Toucher1.x > AppSize.x * 0.3) and (Toucher1.x < AppSize.x * 0.7) and (Toucher1.y > AppSize.y * 0.8)
		LightHeadlight = (Toucher1.x > AppSize.x * 0.3) and (Toucher1.x < AppSize.x * 0.7) and (Toucher1.y < AppSize.y * 0.3)
		HighBeamsTouch1 = (((Toucher1.x < AppSize.x * 0.15) or (Toucher1.x > AppSize.x * 0.85)) and (Toucher1.y < AppSize.y * 0.5))
		HazardTouch1 = (((Toucher1.x < AppSize.x * 0.15) or (Toucher1.x > AppSize.x * 0.85)) and (Toucher1.y > AppSize.y * 0.5))

		if LightLTurn and PadButton and not Touch2.down then
			TouchingColor1 = rgbm(1, 1, 0, 1)
			debounceValues(Lights.TurnLeft,1000)
		end

		if LightRTurn and PadButton and not Touch2.down then
			TouchingColor1 = rgbm(1, 1, 0, 1)
			debounceValues(Lights.TurnRight,1000)
		end

		if LightOff and PadButton then
			TouchingColor1 = rgbm(1,1,0,1)
			debounceValues(Lights.Off,1000)
		end

		if LightHeadlight and PadButton then
			TouchingColor1 = rgbm(1,1,1,1)
			debounceValues(Lights.Headlights,1000)
		end

		--#region Touch2
		if Touch2.down then
			Toucher2 = vec2(interp(0, 0.959500, Touch2.pos.x, 0, AppSize.x), interp(0, 0.526855, Touch2.pos.y, 0, AppSize.y))
			TouchingColor2 = rgbm(0, 1, 0.5, 0.5)
			--Color Change when pressing
			if PadButton then
				TouchingColor2 = rgbm(0, 1, 0.5, 1)
			end
			HighBeamsTouch2 = (((Toucher2.x < AppSize.x * 0.15) or (Toucher2.x > AppSize.x * 0.85)) and (Toucher2.y < AppSize.y * 0.5))
			HazardTouch2 = (((Toucher2.x < AppSize.x * 0.15) or (Toucher2.x > AppSize.x * 0.85)) and (Toucher2.y > AppSize.y * 0.5))
		end
		--#endregion
	end

	if HighBeamsTouch1 and HighBeamsTouch2 and PadButton then
		TouchingColor1 = rgbm(1, 1, 1, 1)
		TouchingColor2 = rgbm(1, 1, 1, 1)
		debounceValues(Lights.Highbeams,1000)
	end

	--Hazards thing
	if HazardTouch1 and HazardTouch2 and PadButton then
		TouchingColor1 = rgbm(1, 1, 0, 1)
		TouchingColor2 = rgbm(1, 1, 0, 1)
		debounceValues(Lights.Hazards,1000)
	end

	if Touch1.down then
		ui.drawCircleFilled(Toucher1, 10, TouchingColor1, 24)
		if Touch2.down then
			ui.drawCircleFilled(Toucher2, 10, TouchingColor2, 24)
		end
	end
end

if settings.Controller == "PS" then
	Face_Right	= Facebuttons.PS.Face_Right
	Face_Down 	= Facebuttons.PS.Face_Down
	Face_Left 	= Facebuttons.PS.Face_Left
	Face_Up		= Facebuttons.PS.Face_Up
end

function Main()
		ui.drawRectFilled(0, AppSize, settings.BackgroundColor, 5, nil)
		Middle()
		F_Face_Right()
		F_Face_Down()
		F_Face_Left()
		F_Face_Up()
		LeftStick()
		RightStick()
		LeftTrigger()
		RightTrigger()
		TouchingStory()
end

function ControllerInput()
	--#region [[App Size]]
	AppPos = ui.windowPos()
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
	ui.transparentWindow("##ATransparentWindow", AppPos, AppSize,Main)
end
