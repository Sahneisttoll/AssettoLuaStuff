


local FirstRun = true
local sim = ac.getSim()
local car = ac.getCar(0)
local GameSize = vec2(sim.windowWidth, sim.windowHeight)
local AppPos = vec2()
local AppSize = vec2()
local Scale = 0

local Controller = 0
local LeftStick = vec2()
local RightStick= vec2()
local Triggers 	= vec2()
local LeftStickMiddle 	= vec2()
local RightStickMiddle 	= vec2()

local dualsense = ac.getDualSense(4)
if dualsense ~= nil then
	local Touch1 = dualsense.touches[0]
	local Touch2 = dualsense.touches[1]
end

--#region [Luts]
local TriggerStart = math.rad(179)
local TriggerEnd = math.rad(361)
local TriggerLut = ac.DataLUT11():add(0, TriggerStart):add(1, TriggerEnd)
TriggerLut.extrapolate = true

local ScaleLut = ac.DataLUT11():add(512,1):add(1024,2)
ScaleLut.extrapolate = true
--#endregion


function GetControllerIndex()
	for GamepadIndex = 0, 7 do
		for Axis = 0, 5 do 
			if ac.getGamepadAxisValue(GamepadIndex, Axis) > 0.01 then
				Controller = GamepadIndex
			end
		end
	end
	FirstRun = false
end

function script.update()
	if FirstRun == true then
		GetControllerIndex()
		ac.debug("Cont",Controller)
	end
end
--real steer -1 to 1   RealSteering = car.steer/car.steerLock


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
	--#endregion

	ui.transparentWindow("##ATransparentWindow", AppPos, AppSize, function()
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
	end)
end
