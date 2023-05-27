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
local BackgroundFill 	= vec2()

--#region [Luts]
--triggers
local TriggerStart = math.rad(180)
local TriggerEnd = math.rad(360)

local TriggerLut = ac.DataLUT11():add(0, TriggerStart):add(1, TriggerEnd)
TriggerLut.extrapolate = true

local function PotClamp(StickX,StickY)
	local stick_radius = math.sqrt((StickX ^2) + (StickY ^2))
	if (stick_radius > 1) then
		StickX = StickX / stick_radius
		StickY = StickY / stick_radius
	end
	return vec2(StickX,StickY)
end

--	interp(0,math.rad(179),trigger here,1,math.rad(361))

--scaling
local ScaleLut = ac.DataLUT11():add(512,1):add(1024,2)
ScaleLut.extrapolate = true
--#endregion

function script.update()

	if Controller == -1 then
		--[[ after 10 seconds with no input seen by this it will default to 0,
		this is only here cause specific controllers have their own minimal deadzone and i dont want this to run infinite]]
		setTimeout(function () if Controller == -1 then Controller = 0 end end, 15, "Controllertimeout")
		for GamepadIndex = 0, 8 do
			for Axis = 0, 5 do
				if ac.getGamepadAxisValue(GamepadIndex, Axis) > 0.000001 then
					Controller = GamepadIndex
					clearTimeout("Controllertimeout")
				end
				--[[
				if ac.getJoystickAxisValue(GamepadIndex,Axis) > 0.000001 then
					Controller = 4
					clearTimeout("Controllertimeout")
				end
				]]
			end
		end
	end
	
	--#region Debugging ahahaheheheh
	--[[]]
	for GamepadIndex = 0, 8 do
		for Axis = 0, 5 do
			ac.debug("Index " .. GamepadIndex.."|Axis "..Axis ,
			"Gamepad: " .. math.round(ac.getGamepadAxisValue(GamepadIndex, Axis),3) .. 
			"     Joy pad: " .. math.round(ac.getJoystickAxisValue(GamepadIndex,Axis),3))
		end
	end
	--[[]]
	ac.debug("What Input am i?", Controller < 4 and "Xinput: " .. tostring(Controller) or Controller >= 4 and "DINPUT: " .. tostring(Controller))
	--#endregion
end

--#region Icons
local DPAD_Icon 	= ac.dirname() .. "\\DPAD.png"
local DPAD_UP_ON 	= ui.atlasIconID(DPAD_Icon, vec2(0.5, 0)	, vec2(1, 0.25))
local DPAD_UP_OFF 	= ui.atlasIconID(DPAD_Icon, vec2(0, 0)	, vec2(0.5, 0.25))

local DPAD_RIGHT_ON = ui.atlasIconID(DPAD_Icon, vec2(0.5, 0.25)	, vec2(1, 0.5))
local DPAD_RIGHT_OFF= ui.atlasIconID(DPAD_Icon, vec2(0, 0.25)	, vec2(0.5, 0.5))

local DPAD_DOWN_ON 	= ui.atlasIconID(DPAD_Icon, vec2(0.5, 0.5)	, vec2(1, 0.75))
local DPAD_DOWN_OFF = ui.atlasIconID(DPAD_Icon, vec2(0, 0.5)	, vec2(0.5, 0.75))

local DPAD_LEFT_ON 	= ui.atlasIconID(DPAD_Icon, vec2(0.5, 0.75), vec2(1, 1))
local DPAD_LEFT_OFF = ui.atlasIconID(DPAD_Icon, vec2(0, 0.75), vec2(0.5, 1))


local RightOne 		= ac.dirname() .. "\\brah.png"
local ShiftUp_ON 	= ui.atlasIconID(RightOne, vec2(0.5, 0)	, vec2(1, 0.25))
local ShiftUp_OFF 	= ui.atlasIconID(RightOne, vec2(0, 0)	, vec2(0.5, 0.25))

local ShiftDown_ON 	= ui.atlasIconID(RightOne, vec2(0.5, 0.25)	, vec2(1, 0.5))
local ShiftDown_OFF = ui.atlasIconID(RightOne, vec2(0, 0.25)	, vec2(0.5, 0.5))

local HandBreak_ON 	= ui.atlasIconID(RightOne, vec2(0.5, 0.5)	, vec2(1, 0.75))
local HandBreak_OFF = ui.atlasIconID(RightOne, vec2(0, 0.5)	, vec2(0.5, 0.75))

local Clutch_ON 	= ui.atlasIconID(RightOne, vec2(0.5, 0.75), vec2(1, 1))
local Clutch_OFF 	= ui.atlasIconID(RightOne, vec2(0, 0.75), vec2(0.5, 1))
--#endregion

function ControllerInput()
	AppPos 	= ui.windowPos()
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
	LeftStick 	= vec2(ac.getGamepadAxisValue(Controller, ac.GamepadAxis.LeftThumbX),-ac.getGamepadAxisValue(Controller, ac.GamepadAxis.LeftThumbY))
	RightStick 	= vec2(ac.getGamepadAxisValue(Controller, ac.GamepadAxis.RightThumbX),-ac.getGamepadAxisValue(Controller, ac.GamepadAxis.RightThumbY))
	Triggers 	= vec2(ac.getGamepadAxisValue(Controller, ac.GamepadAxis.LeftTrigger),ac.getGamepadAxisValue(Controller, ac.GamepadAxis.RightTrigger))
	RealSteering= vec2(car.steer / car.steerLock, 0)
	LeftStick 	= PotClamp(LeftStick.x,LeftStick.y)
	RightStick 	= PotClamp(RightStick.x,RightStick.y)
	--#endregion
	--#region number stuff with scaling
	StickBoundsRadius 	= 100 	* Scale
	StickBoundSegments  = 48	* Scale
	StickRadius 		= 20 	* Scale
	StickSegments 		= 24 	* Scale

	RealSteeringRadius 	= 8 	* Scale
	RealSteeringSegments= 12 	* Scale

	TriggerWidth		= 8		* Scale
	TriggerRadius 		= 105 	* Scale
	TriggerSegments		= 32	* Scale
	--#endregion

	--#region vec2 stuff with scaling
	Triggers		:set(vec2(TriggerLut:get(Triggers.x),TriggerLut:get(Triggers.y)))
	LeftStick		:scale(80)			:scale(Scale)
	LeftStickMiddle	:set(vec2(128,128))	:scale(Scale)
	RealSteering	:scale(93)			:scale(Scale)
	RightStick		:scale(80)			:scale(Scale)
	RightStickMiddle:set(vec2(384,128))	:scale(Scale)
	BackgroundFill	:set(vec2(512,256))	:scale(Scale)

	DPAD_color		= rgbm(1,1,1,0.8)
	Dpad_pos_up		= LeftStickMiddle + vec2(-32,-96) * Scale
	Dpad_pos_right	= LeftStickMiddle + vec2(32,-32)  * Scale
	Dpad_pos_down	= LeftStickMiddle + vec2(-32,32)  * Scale
	Dpad_pos_left	= LeftStickMiddle + vec2(-96,-32) * Scale
	DPAD_Size		= 64 * Scale

	other_color		= rgbm(1,1,1,0.8)
	other_pos_up	= RightStickMiddle + vec2(-32,-96) * Scale
	other_pos_right	= RightStickMiddle + vec2(32,-32)  * Scale
	other_pos_down	= RightStickMiddle + vec2(-32,32)  * Scale
	other_pos_left	= RightStickMiddle + vec2(-96,-32) * Scale
	other_Size		= 64 * Scale
	--#endregion

	ui.transparentWindow("##ATransparentWindow", AppPos, AppSize, function()
		ui.drawRectFilled(0, BackgroundFill, rgbm(0, 0, 0,0.4), 20, ui.CornerFlags.All)
		--Break
		
		ui.pathArcTo(LeftStickMiddle, TriggerRadius, TriggerStart, TriggerEnd, TriggerSegments)
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, TriggerWidth)
		ui.pathArcTo(LeftStickMiddle, TriggerRadius, TriggerStart, Triggers.x , TriggerSegments)
		ui.pathStroke(rgbm(1, 0, 0, 0.8), false, TriggerWidth)
		--Gas
		ui.pathArcTo(RightStickMiddle, TriggerRadius, TriggerStart, TriggerEnd, TriggerSegments)
		ui.pathStroke(rgbm(1, 1, 1, 0.3), false, TriggerWidth)
		ui.pathArcTo(RightStickMiddle, TriggerRadius, TriggerStart, Triggers.y, TriggerSegments)
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

		--[[
			thanks csp80p218 for breaking it
			if ac.isControllerGearUpPressed() then 
		]]
		if ac.isGamepadButtonPressed(Controller,ac.GamepadButton.X) then -- temp fix maybe read from the ini next time lol
			ui.icon(ShiftUp_ON,DPAD_Size,other_color)
		else
			ui.icon(ShiftUp_OFF,DPAD_Size,other_color)
		end

		ui.setCursor(other_pos_down)
		--[[
			thanks csp80p218 for breaking it		
			if ac.isControllerGearDownPressed() then 
		]]
		if ac.isGamepadButtonPressed(Controller,ac.GamepadButton.A) then -- temp fix maybe read from the ini next time lol
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
