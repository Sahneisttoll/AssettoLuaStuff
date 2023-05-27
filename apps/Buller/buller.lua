--#region [[TP/ram thing]]
local time = 0
local oldme = {	
	pos=vec3(),
	vel=vec3(),
	dir=vec3(),
	tp=0,
}

local function rdm()
	ui.text("is *physics.* usage allowed\n via app? The answer is: " .. tostring(physics.allowed()))
	ui.newLine(10)
	ui.childWindow("##drivers", vec2(ui.availableSpaceX(), ui.availableSpaceY()), function()
		ui.text(time)
		--ui.text("Old Pos		|"..stringify(oldme.pos))
		--ui.text("Current Pos	|"..stringify(ac.getCar(0).position))

		if ui.button("Trolled") and selectedCar then
			oldme.pos = ac.getCar(0).position
			oldme.dir = ac.getCar(0).look
			oldme.vel = ac.getCar(0).velocity
			local dir = selectedCar.look
			local pos = selectedCar.position
			local vel = selectedCar.velocity
			physics.setCarPosition(0, pos + vec3(0, 0.1, 0) - dir * 8, -dir)
			physics.setCarVelocity(0,vel*vec3(5,0,5))
			time = 0.3
			oldme.tp = 1
		end

		if time < 0 and oldme.tp == 1 then
			oldme.tp = 2
		end

		if oldme.tp == 2 then
			physics.setCarPosition(0,oldme.pos,-oldme.dir)
			physics.setCarVelocity(0,oldme.vel)
			oldme.tp = 0
		end

		for i = 1, ac.getSim().carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			if ui.selectable(driverName, selectedCar == car) then
				selectedCar = car
			end
		end
	end)
end
--#endregion

--#region [[Driver Eyes]]
local cur_onboard = {
	position = vec3(),
	pitch = 0,
	yaw = 0,
}
local onboad_change = refbool(false)

local function SetSeat()
	local Onboard_Default = ac.getOnboardCameraDefaultParams()
	ui.text("Default")
	ui.text("Position :" .. tostring(Onboard_Default.position))
	ui.text("Pitch     :" .. tostring(Onboard_Default.pitch))
	ui.text("Yaw      :" .. tostring(Onboard_Default.yaw))
	ui.separator()
	local Onboard_Current = ac.getOnboardCameraParams()
	ui.text("Current")
	ui.text("Position :" .. tostring(Onboard_Current.position))
	ui.text("Pitch     :" .. tostring(Onboard_Current.pitch))
	ui.text("Yaw      :" .. tostring(Onboard_Current.yaw))
	ui.newLine(-15)
	if ui.button("Reset") then
		cur_onboard.position = Onboard_Default.position
		cur_onboard.pitch = Onboard_Default.pitch
		cur_onboard.yaw = Onboard_Default.yaw
		ac.setOnboardCameraParams(0,ac.SeatParams(cur_onboard.position,cur_onboard.pitch,cur_onboard.yaw))
	end
	ui.sameLine(0,2)
	if ui.button(onboad_change.value == true and "End Changing" or onboad_change.value == false and "Start Changing") then
		onboad_change.value = not onboad_change.value
	end
	if onboad_change.value == true then
		--load them with current
		if cur_onboard.position == vec3() then
			cur_onboard.position= Onboard_Current.position
			cur_onboard.pitch 	= Onboard_Current.pitch
			cur_onboard.yaw 	= Onboard_Current.yaw
		end
		ui.setNextItemWidth(ui.windowWidth()-25)
		local _x 	= ui.slider("###_x",cur_onboard.position.x,2,-2,"X: %.3f")
		ui.setNextItemWidth(ui.windowWidth()-25)
		local _y 	= ui.slider("###_y",cur_onboard.position.y,2,-2,"Y: %.3f")
		ui.setNextItemWidth(ui.windowWidth()-25)
		local _z 	= ui.slider("###_z",cur_onboard.position.z,2,-2,"Z: %.3f")
		ui.setNextItemWidth(ui.windowWidth()-25)
		local _pitch= ui.slider("###_pitch",cur_onboard.pitch,2,-2,"pitch: %.3f")
		ui.setNextItemWidth(ui.windowWidth()-25)
		local _yaw 	= ui.slider("###_yaw",cur_onboard.yaw,2,-2,"Yaw: %.3f")

		if _x or _y or _z or _pitch or _yaw then
			cur_onboard.position:set(_x,_y,_z)
			cur_onboard.pitch = _pitch
			cur_onboard.yaw = _yaw
			ac.setOnboardCameraParams(0,ac.SeatParams(cur_onboard.position,cur_onboard.pitch,cur_onboard.yaw))
		end
	end
end
--#endregion



local function funnytp()
	if ui.button("reset") then
		ac.resetCar()
	end
	if ui.button("step back") then
		ac.takeAStepBack()
	end
end
--#endregion

--#region [[ver]]
local function ver()
	ui.text("Running CSP version: '"..ac.getPatchVersion().."' or also called '".. ac.getPatchVersionCode().."'")
	local getfov = ac.getCameraFOV()
	funnie = getfov
	ui.setNextItemWidth(ui.availableSpaceX())
	local funnie, changed = ui.slider("##2cammy", funnie, 0.001, 50, "Fov: %.04f", 4)
	if changed then
		fovthing = funnie
		ac.setCameraFOV(fovthing)
	end
end
--#endregion



local sim = ac.getSim()
local car = ac.getCar(0)

local lastDistanceTraveled = 0
local lastFuelMeasurement = 0
local fuelAtStart = 0
local distanceTraveledAtStart = 0
local UsedFuel = 0
local RemainingFuel = 0
local InPits = 0
local DistanceTraveled = 0
local distance = 0
local KMPerL = 0

local function Fueltest()
	ui.text("RemainingFuel:  	"		..	math.round(RemainingFuel,2))
	ui.text("liters used:			"	..	math.round(UsedFuel,2))
	--ui.text("DistanceTraveled:  "		..	math.round(DistanceTraveled,2))
	ui.text("distance after pit:  "		..	math.round(distance,2))
	ui.text("l/100km:   "				..	math.round(LiterPer100KM,2))

	--fuel usage
	ui.pathArcTo(vec2(100,250),35,math.rad(180),math.rad(360),12)
	ui.pathStroke(rgbm(1,1,0,1), false, 6)
	ui.pathArcTo(vec2(100,250),35,math.rad(180),math.rad(radthing),12)
	ui.pathStroke(rgbm(1,0,0,1), false, 6)
end

--#region [[main shizz]]
local nuke = false
function script.windowMain()
	if ui.checkbox("empty", nuke) then
		nuke = not nuke
	end
	if nuke then
		return
	end
	ui.tabBar("someTabBarID", bit.bor(ui.TabBarFlags.NoTooltip), function()
		ui.tabItem("rdm", rdm)
		ui.tabItem("Seating", SetSeat)
		ui.tabItem("Phy", funnytp)
		ui.tabItem("version", ver)
		ui.tabItem("fuul", Fueltest)

	end)
end

function script.update(dt)

	RemainingFuel 	= car.fuel
	InPits			= car.isInPit
	DistanceTraveled= car.distanceDrivenSessionKm

	if InPits == true or lastFuelMeasurement < RemainingFuel or lastFuelMeasurement - 2 > RemainingFuel then
		fuelAtStart 			= RemainingFuel
		distanceTraveledAtStart = DistanceTraveled
	end

	distance = DistanceTraveled - distanceTraveledAtStart

	UsedFuel = fuelAtStart - RemainingFuel


	LiterPer100KM = UsedFuel / distance * 100

	lastFuelMeasurement = RemainingFuel
	lastDistanceTraveled = DistanceTraveled

	main = (car.rpm*car.gas)
	sec = (car.rpmLimiter*1)
	radthing = math.lerp(180,360,math.lerpInvSat(main,0,sec))

end
--#endregion