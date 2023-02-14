local ShowLeName = true
local ToggleLeName = false
local function newnames()
	local Button = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)

	--does magic that the button is only pressed once
	if Button == ToggleLeName then
		return
	end

	--do things in here
	if Button == true then
		ShowLeName = not ShowLeName
		if ShowLeName == true then ui.toast(ui.Icons.Bug, "Names Enabled") else ui.toast(ui.Icons.Bug, "Names Disabled") end
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
function script.fullscreenUI()
	newnames()
	if ShowLeName == true then
		local sim = ac.getSim()
		local focusedCar = ac.getCar(sim.focusedCar)

		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)

			if
				car.isConnected --[[and not car.isAIControlled]]
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
end