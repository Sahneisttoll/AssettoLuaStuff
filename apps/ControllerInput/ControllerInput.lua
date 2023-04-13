local sim = ac.getSim()
local car = ac.getCar(0)
local AppPos = vec2()
local AppSize = vec2()
local Scale = 0

local Controller = -1
local LeftStick = vec2()
local RightStick= vec2()
local Triggers 	= vec2()
local LeftStickMiddle 	= vec2()
local RightStickMiddle 	= vec2()

--#region [Luts]
local TriggerStart = math.rad(179)
local TriggerEnd = math.rad(361)
local TriggerLut = ac.DataLUT11():add(0, TriggerStart):add(1, TriggerEnd)
TriggerLut.extrapolate = true

local ScaleLut = ac.DataLUT11():add(512,1):add(1024,2)
ScaleLut.extrapolate = true
--#endregion

function script.update()
	if Controller == -1 then
		for GamepadIndex = 0, 7 do
			for Axis = 0, 5 do 
				if ac.getGamepadAxisValue(GamepadIndex, Axis) > 0.000001 then
					Controller = GamepadIndex
				end
			end
		end
	end
	ac.debug("What Input am i?", Controller < 4 and "Xinput: " .. tostring(Controller) or Controller >= 4 and "DINPUT: " .. tostring(Controller))
end

local DPAD_Icon = ac.dirname() .. "\\DPAD.png"
local DPAD_UP_ON = ui.atlasIconID(DPAD_Icon, vec2(0.5, 0)	, vec2(1, 0.25))
local DPAD_UP_OFF = ui.atlasIconID(DPAD_Icon, vec2(0, 0)	, vec2(0.5, 0.25))

local DPAD_RIGHT_ON = ui.atlasIconID(DPAD_Icon, vec2(0.5, 0.25)	, vec2(1, 0.5))
local DPAD_RIGHT_OFF = ui.atlasIconID(DPAD_Icon, vec2(0, 0.25)	, vec2(0.5, 0.5))

local DPAD_DOWN_ON = ui.atlasIconID(DPAD_Icon, vec2(0.5, 0.5)	, vec2(1, 0.75))
local DPAD_DOWN_OFF = ui.atlasIconID(DPAD_Icon, vec2(0, 0.5)	, vec2(0.5, 0.75))

local DPAD_LEFT_ON = ui.atlasIconID(DPAD_Icon, vec2(0.5, 0.75), vec2(1, 1))
local DPAD_LEFT_OFF = ui.atlasIconID(DPAD_Icon, vec2(0, 0.75), vec2(0.5, 1))


local RightOne = ac.dirname() .. "\\brah.png"
local ShiftUp_ON = ui.atlasIconID(RightOne, vec2(0.5, 0)	, vec2(1, 0.25))
local ShiftUp_OFF = ui.atlasIconID(RightOne, vec2(0, 0)	, vec2(0.5, 0.25))

local ShiftDown_ON = ui.atlasIconID(RightOne, vec2(0.5, 0.25)	, vec2(1, 0.5))
local ShiftDown_OFF = ui.atlasIconID(RightOne, vec2(0, 0.25)	, vec2(0.5, 0.5))

local HandBreak_ON = ui.atlasIconID(RightOne, vec2(0.5, 0.5)	, vec2(1, 0.75))
local HandBreak_OFF = ui.atlasIconID(RightOne, vec2(0, 0.5)	, vec2(0.5, 0.75))

local Clutch_ON = ui.atlasIconID(RightOne, vec2(0.5, 0.75), vec2(1, 1))
local Clutch_OFF = ui.atlasIconID(RightOne, vec2(0, 0.75), vec2(0.5, 1))


function ControllerInput()
	AppPos = ui.windowPos()
	AppSize = ui.windowSize()


	winWidth 	= AppSize.x
	winHeight 	= AppSize.y

	--#region Scaling
	ratio = winWidth / winHeight
	if ratio < 2 then
		winHeight = winWidth
	else
		winWidth = winHeight * 2
	end
	Scale = ScaleLut:get(winWidth)
	--#endregion

	--#region Get Shit
	LeftStick = vec2(ac.getGamepadAxisValue(Controller, ac.GamepadAxis.LeftThumbX),-ac.getGamepadAxisValue(Controller, ac.GamepadAxis.LeftThumbY))
	RightStick = vec2(ac.getGamepadAxisValue(Controller, ac.GamepadAxis.RightThumbX),-ac.getGamepadAxisValue(Controller, ac.GamepadAxis.RightThumbY))
	Triggers = vec2(ac.getGamepadAxisValue(Controller, ac.GamepadAxis.LeftTrigger),ac.getGamepadAxisValue(Controller, ac.GamepadAxis.RightTrigger))
	RealSteering = vec2(car.steer / car.steerLock, 0)
	--#endregion

	--#region number stuff with scaling
	StickBoundsRadius 	= 100 	* Scale
	StickBoundSegments  = 48	* Scale
	StickRadius 		= 25 	* Scale
	StickSegments 		= 24 	* Scale

	RealSteeringRadius 	= 8 	* Scale
	RealSteeringSegments= 12 	* Scale

	TriggerWidth		= 8		* Scale
	TriggerRadius 		= 120 	* Scale
	TriggerSegments		= 32	* Scale
	--#endregion

	--#region vec2 stuff with scaling
	Triggers:set(vec2(TriggerLut:get(Triggers.x),TriggerLut:get(Triggers.y)))
	LeftStickMiddle:set(vec2(128,128)):scale(Scale)
	LeftStick	:scale(100):scale(Scale)
	RealSteering:scale(100):scale(Scale)
	RightStickMiddle:set(vec2(384,128)):scale(Scale)
	RightStick	:scale(100):scale(Scale)

	DPAD_color		= rgbm(1,1,1,0.8)
	Dpad_pos_up		= LeftStickMiddle + vec2(-32,-96) * Scale
	Dpad_pos_right	= LeftStickMiddle + vec2(32,-32) * Scale
	Dpad_pos_down	= LeftStickMiddle + vec2(-32,32) * Scale
	Dpad_pos_left	= LeftStickMiddle + vec2(-96,-32) * Scale
	DPAD_Size		= 64 * Scale

	other_color		= rgbm(1,1,1,0.8)
	other_pos_up	= RightStickMiddle + vec2(-32,-96) * Scale
	other_pos_right	= RightStickMiddle + vec2(32,-32) * Scale
	other_pos_down	= RightStickMiddle + vec2(-32,32) * Scale
	other_pos_left	= RightStickMiddle + vec2(-96,-32) * Scale
	other_Size		= 64 * Scale
	--#endregion

	ui.transparentWindow("##ATransparentWindow", AppPos, AppSize, function()
		--ui.drawLine(LeftStickMiddle-vec2(100,0),LeftStickMiddle+vec2(100,0),rgbm.colors.black,3)
		--ui.drawLine(LeftStickMiddle-vec2(0,100),LeftStickMiddle+vec2(0,100),rgbm.colors.black,3)

		ui.drawRectFilled(0, AppSize, rgbm(0, 0, 0, 0.2), 15, ui.CornerFlags.All)
		--Break
		ui.pathArcTo(LeftStickMiddle, TriggerRadius, TriggerStart, TriggerEnd, TriggerSegments)
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, TriggerWidth)
		ui.pathArcTo(LeftStickMiddle, TriggerRadius, TriggerStart, Triggers.x , TriggerSegments)
		ui.pathStroke(rgbm(1, 0, 0, 0.8), false, TriggerWidth)
		--Gas
		ui.pathArcTo(RightStickMiddle, TriggerRadius, TriggerStart, TriggerEnd, TriggerSegments)
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, TriggerWidth)
		ui.pathArcTo(RightStickMiddle, TriggerRadius, TriggerStart, Triggers.y , TriggerSegments)
		ui.pathStroke(rgbm(0, 1, 0, 0.8), false, TriggerWidth)

		--LeftStick + Steering Output
		ui.drawCircle(LeftStickMiddle, StickBoundsRadius, rgbm(1, 1, 1, 0.8), StickBoundSegments, 2)
		ui.drawCircleFilled(LeftStickMiddle + LeftStick, StickRadius, rgbm(1, 1, 1, 0.8), StickSegments)
		ui.drawCircleFilled(LeftStickMiddle + RealSteering, RealSteeringRadius, rgbm(1, 0, 0, 0.8), RealSteeringSegments)
		--RightStick
		ui.drawCircle(RightStickMiddle, StickBoundsRadius, rgbm(1, 1, 1, 0.8), StickBoundSegments, 2)
		ui.drawCircleFilled(RightStickMiddle + RightStick, StickRadius, rgbm(1, 1, 1, 0.8), StickSegments)

		--DPAD
		ui.setCursor(Dpad_pos_up)
		if ac.isGamepadButtonPressed(Controller,ac.GamepadButton.DPadUp) then
			ui.icon(DPAD_UP_ON,DPAD_Size,DPAD_color)
		else
			ui.icon(DPAD_UP_OFF,DPAD_Size,DPAD_color)
		end

		ui.setCursor(Dpad_pos_right)
		if ac.isGamepadButtonPressed(Controller,ac.GamepadButton.DPadRight) then
			ui.icon(DPAD_RIGHT_ON,DPAD_Size,DPAD_color)
		else
			ui.icon(DPAD_RIGHT_OFF,DPAD_Size,DPAD_color)
		end

		ui.setCursor(Dpad_pos_down)
		if ac.isGamepadButtonPressed(Controller,ac.GamepadButton.DPadDown) then
			ui.icon(DPAD_DOWN_ON,DPAD_Size,DPAD_color)
		else
			ui.icon(DPAD_DOWN_OFF,DPAD_Size,DPAD_color)
		end

		ui.setCursor(Dpad_pos_left)
		if ac.isGamepadButtonPressed(Controller,ac.GamepadButton.DPadLeft) then
			ui.icon(DPAD_LEFT_ON,DPAD_Size,DPAD_color)
		else
			ui.icon(DPAD_LEFT_OFF,DPAD_Size,DPAD_color)
		end

		--rightstick one
		ui.setCursor(other_pos_left)
		if ac.isControllerGearUpPressed() then
			ui.icon(ShiftUp_ON,DPAD_Size,other_color)
		else
			ui.icon(ShiftUp_OFF,DPAD_Size,other_color)
		end

		ui.setCursor(other_pos_down)
		if ac.isControllerGearDownPressed() then
			ui.icon(ShiftDown_ON,DPAD_Size,other_color)
		else
			ui.icon(ShiftDown_OFF,DPAD_Size,other_color)
		end

		ui.setCursor(other_pos_right)
		if car.handbrake > 0 then
			ui.icon(HandBreak_ON,DPAD_Size,other_color)
		else
			ui.icon(HandBreak_OFF,DPAD_Size,other_color)
		end

		ui.setCursor(other_pos_up)
		if car.clutch < 0.9 then
			ui.icon(Clutch_ON,DPAD_Size,other_color)
		else
			ui.icon(Clutch_OFF,DPAD_Size,other_color)
		end
		
	end)
end
