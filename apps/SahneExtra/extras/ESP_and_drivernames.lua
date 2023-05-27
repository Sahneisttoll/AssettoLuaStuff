local ToggleLeName = false
local sim = ac.getSim()
function DriverNames_Toggle()
	local Button = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
	--does magic that the button is only pressed once
	if Button == ToggleLeName then
		return
	end
	--do things in here
	if Button == true then
		settings.ShowLeName = not settings.ShowLeName
		if settings.ShowLeName == true then ui.toast(ui.Icons.Bug, "Names Enabled") else ui.toast(ui.Icons.Bug, "Names Disabled") end
	end
	--does magic that the button is only pressed once
	ToggleLeName = Button
end

Alpha = ac.DataLUT11.parse([[(
|5=1|
|25=1|
|50=0.5|
|100=0|)]])
Alpha.extrapolate = true

NameLutHeight = ac.DataLUT11.parse([[(
|0=-0.2|
|5=-0.2|
|12.5=0.3|
|25=1|
|35=1.5|
|50=3.6|
|60=10|
|70=30|)]])
NameLutHeight.extrapolate = true

local DistanceBetweenMeAndYou = 0
local NameSize = 15
function DriverNames_Draw()
	local focusedCar = ac.getCar(sim.focusedCar)
	for i = 0, sim.carsCount - 1 do
		local car = ac.getCar(i)
		local driverName = ac.getDriverName(i)
		if	car.isConnected
			--[[and not car.isAIControlled]]
			and not string.find(driverName, "Traffic")
			and not string.find(driverName, ac.getDriverName(sim.focusedCar))
		then
			if sim.isFreeCameraOutside == true then
				DistanceBetweenMeAndYou = math.distance(car.position, sim.cameraPosition)
			else
				DistanceBetweenMeAndYou = math.distance(car.position, focusedCar.position)
			end
			if DistanceBetweenMeAndYou < 100 then
				local NameAlpha = Alpha:get(DistanceBetweenMeAndYou)
				local extraheight = NameLutHeight:get(DistanceBetweenMeAndYou) + car.aabbSize.x

				local screenpos = ui.projectPoint(car.position + vec3(0, extraheight, 0))

				local textsize = ui.measureDWriteText(driverName, NameSize) / 2
				ui.dwriteDrawText(driverName, NameSize, screenpos - textsize, rgbm(1, 1, 1, NameAlpha))
			end
		end
	end
end


function ESP3D()
	if settings.ESP3DLines or settings.ESP3DBoxes then
		local focusedCar = ac.getCar(sim.focusedCar)
		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			local distance = math.distance(focusedCar.position, car.position)

			if settings.ESP3DFromCam == true then
				distance = math.distance(sim.cameraPosition, car.position)
			end

			if distance < settings.ESPMaxDist and car.isConnected then
				local CarColor = rgbm(1, 1, 1, 1)
				if car.isAIControlled and not string.find(driverName, ac.getDriverName(sim.focusedCar)) then
					CarColor = rgbm(1, 1, 0, 1) -- blue ai car
				end
				if
					string.find(driverName, "Traffic") and not string.find(driverName, ac.getDriverName(sim.focusedCar))
				then
					CarColor = rgbm(1, 0, 0, 1) -- red traffic
				end

				if settings.ESP3DLines == true then
					local Origin = focusedCar.position + vec3(0, focusedCar.aabbSize.y, 0)
					if settings.ESP3DFromCam ~= false then
						Origin = sim.cameraPosition + sim.cameraLook * 2 + sim.cameraUp
					end
					local Target = car.position + vec3(0, car.aabbSize.y, 0)

					render.debugLine(Origin, Target, CarColor)
				end

				if settings.ESP3DBoxes == true then

					--ac.debug("1 C "	..driverName	,car.aabbCenter)
					--ac.debug("2 S "	..driverName	,car.aabbSize)

					local FrontBack = (car.look * car.aabbSize.x)
					local Sides = (car.side * (car.aabbSize.x * 0.5))
					local Up = (car.up * car.aabbSize.y)

					local Lower_Top_Left = car.position + FrontBack + Sides
					local Lower_Rear_Left = car.position - FrontBack + Sides
					local Lower_Top_Right = car.position + FrontBack - Sides
					local Lower_Rear_Right = car.position - FrontBack - Sides

					local Upper_Top_Left = Lower_Top_Left + Up
					local Upper_Rear_Left = Lower_Rear_Left + Up
					local Upper_Top_Right = Lower_Top_Right + Up
					local Upper_Rear_Right = Lower_Rear_Right + Up

					render.debugLine(Lower_Top_Left, Lower_Rear_Left, CarColor)
					render.debugLine(Lower_Top_Right, Lower_Rear_Right, CarColor)
					render.debugLine(Lower_Top_Left, Lower_Top_Right, CarColor)
					render.debugLine(Lower_Rear_Left, Lower_Rear_Right, CarColor)

					render.debugLine(Upper_Top_Left, Upper_Rear_Left, CarColor)
					render.debugLine(Upper_Top_Right, Upper_Rear_Right, CarColor)
					render.debugLine(Upper_Top_Left, Upper_Top_Right, CarColor)
					render.debugLine(Upper_Rear_Left, Upper_Rear_Right, CarColor)

					render.debugLine(Lower_Top_Left, Upper_Top_Left, CarColor)
					render.debugLine(Lower_Rear_Left, Upper_Rear_Left, CarColor)
					render.debugLine(Lower_Top_Right, Upper_Top_Right, CarColor)
					render.debugLine(Lower_Rear_Right, Upper_Rear_Right, CarColor)
				end
			end
		end
	end
end

function Line(First, Second, CarColor, Thick)
	return ui.drawLine(ui.projectPoint(First), ui.projectPoint(Second), CarColor, Thick)
end

function ESP2D()
	if settings.ESP2DLines or settings.ESP2DBoxes then
		local focusedCar = ac.getCar(sim.focusedCar)
		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			local distance = math.distance(focusedCar.position, car.position)
			if sim.isFreeCameraOutside then
				distance = math.distance(sim.cameraPosition, car.position)
			end

			if distance < settings.ESPMaxDist and car.isConnected then
				local Alphaing = math.lerp(0, 1, math.lerpInvSat(distance, settings.ESPMaxDist * 0.7, 0))
				local Thickness = math.lerp(0, 2, math.lerpInvSat(distance, settings.ESPMaxDist * 0.7, 0))
				local CarColor = rgbm(1, 1, 1, Alphaing)

				if car.isAIControlled and not string.find(driverName, ac.getDriverName(sim.focusedCar)) then
					CarColor = rgbm(0, 1, 1, Alphaing) -- blue ai car
				end

				if
					string.find(driverName, "Traffic") and not string.find(driverName, ac.getDriverName(sim.focusedCar))
				then
					CarColor = rgbm(1, 0, 0, Alphaing) -- red traffic
				end

				if settings.ESP2DLines == true then
					local Target = car.position + vec3(0, car.aabbSize.y, 0)
					ui.drawLine(vec2(sim.windowWidth / 2, -10), ui.projectPoint(Target), CarColor, 1)
				end

				if settings.ESP2DBoxes == true then
					local FrontBack = (car.look * car.aabbSize.x)
					local Sides	 	= (car.side * (car.aabbSize.x * 0.5))
					local Up 		= (car.up * car.aabbSize.y)
					local Lower_Top_Left = car.position + FrontBack + Sides
					local Lower_Rear_Left = car.position - FrontBack + Sides
					local Lower_Top_Right = car.position + FrontBack - Sides
					local Lower_Rear_Right = car.position - FrontBack - Sides
					local Upper_Top_Left = Lower_Top_Left + Up
					local Upper_Rear_Left = Lower_Rear_Left + Up
					local Upper_Top_Right = Lower_Top_Right + Up
					local Upper_Rear_Right = Lower_Rear_Right + Up
					Line(Lower_Top_Left, Lower_Rear_Left, CarColor, Thickness)
					Line(Lower_Top_Right, Lower_Rear_Right, CarColor, Thickness)
					Line(Lower_Top_Left, Lower_Top_Right, CarColor, Thickness)
					Line(Lower_Rear_Left, Lower_Rear_Right, CarColor, Thickness)
					Line(Upper_Top_Left, Upper_Rear_Left, CarColor, Thickness)
					Line(Upper_Top_Right, Upper_Rear_Right, CarColor, Thickness)
					Line(Upper_Top_Left, Upper_Top_Right, CarColor, Thickness)
					Line(Upper_Rear_Left, Upper_Rear_Right, CarColor, Thickness)
					Line(Lower_Top_Left, Upper_Top_Left, CarColor, Thickness)
					Line(Lower_Rear_Left, Upper_Rear_Left, CarColor, Thickness)
					Line(Lower_Top_Right, Upper_Top_Right, CarColor, Thickness)
					Line(Lower_Rear_Right, Upper_Rear_Right, CarColor, Thickness)
				end
			end
		end
	end
end


function ESPSettings()
	if ui.button(settings.ESP == true and "ESP on" or settings.ESP == false and "ESP off") then
		settings.ESP = not settings.ESP
	end

	if settings.ESP == true then
		ui.sameLine(0,2)
		if ui.button(settings.ESP2D == true and "ESP2D on" or settings.ESP2D == false and "ESP2D off") then
			settings.ESP2D = not settings.ESP2D
		end
		ui.sameLine(0,2)
		if ui.button(settings.ESP3D == true and "ESP3D on" or settings.ESP3D == false and "ESP3D off") then
			settings.ESP3D = not settings.ESP3D
		end
		local HowFar = ui.slider("##linedis",settings.ESPMaxDist,50,2000, 'Distance: %.0f',1)
		if HowFar then
			settings.ESPMaxDist = HowFar
		end
	end
	if settings.ESP2D and settings.ESP then
		if ui.checkbox("2D Boxes",settings.ESP2DBoxes) then
			settings.ESP2DBoxes = not settings.ESP2DBoxes
		end 
		ui.sameLine(0,5)
		if ui.checkbox("2D Lines",settings.ESP2DLines) then
			settings.ESP2DLines = not settings.ESP2DLines
		end
	end
	if settings.ESP3D and settings.ESP then
		if ui.checkbox("3D Boxes",settings.ESP3DBoxes) then
			settings.ESP3DBoxes = not settings.ESP3DBoxes
		end
		if ui.checkbox("3D Lines",settings.ESP3DLines) then
			settings.ESP3DLines = not settings.ESP3DLines
		end
		if settings.ESP3DLines == true then
			ui.sameLine(0,15)
			if ui.checkbox("3D From Cam",settings.ESP3DFromCam) then
				settings.ESP3DFromCam = not settings.ESP3DFromCam
			end
		end
		if ui.checkbox("3D ExtraWalls",settings.ESP3DWallBetter) then
			settings.ESP3DWallBetter = not settings.ESP3DWallBetter
		end
	end
end