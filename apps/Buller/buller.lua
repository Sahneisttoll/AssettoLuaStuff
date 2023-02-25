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
local DriverEyes = {
	pos = vec3(),
	pos1 = 0,
	pos2 = 0,
	pos3 = 0,
	pitch = 0,
	yaw = 0,
}

local function DriverHeadPos()
	local CameraDefault = ac.getOnboardCameraDefaultParams(0)
	ui.text("Default Driver Eye Values")
	ui.text("Position :" .. tostring(CameraDefault.position))
	ui.text("Pitch    :" .. tostring(CameraDefault.pitch))
	ui.text("Yaw      :" .. tostring(CameraDefault.yaw))
	ui.newLine()
	local CameraCurrent = ac.getOnboardCameraParams(0)
	ui.text("Current Driver Eye Values")
	ui.text("Position :" .. tostring(CameraCurrent.position))
	ui.text("Pitch    :" .. tostring(CameraCurrent.pitch))
	ui.text("Yaw      :" .. tostring(CameraCurrent.yaw))
	ui.newLine()

	if ui.button("Reset") then
		local pa, pb, pc = CameraDefault.position:unpack()
		DriverEyes.pos1 = pa
		DriverEyes.pos2 = pb
		DriverEyes.pos3 = pc
		posVec = vec3(DriverEyes.pos1, DriverEyes.pos2, DriverEyes.pos3)
		DriverEyes.pos = posVec
		DriverEyes.pitch = CameraDefault.pitch
		DriverEyes.yaw = CameraDefault.yaw
		ac.setOnboardCameraParams(0, ac.SeatParams(DriverEyes.pos, DriverEyes.pitch, DriverEyes.yaw))
	end

	ui.newLine()
	ui.text("New Position:")
	if ui.checkbox("Enable edit", editeye) then
		editeye = not editeye
	end
	if editeye then
		ui.setNextItemWidth(ui.windowWidth()-25)
		local pos_slider1 = ui.slider("##Pos1", DriverEyes.pos1, -2, 2, "Right & left: %.3f", 1.1)
		ui.setNextItemWidth(ui.windowWidth()-25)
		local pos_slider2 = ui.slider("##Pos2", DriverEyes.pos2, -2, 2, "Down & Up: %.3f", 1.1)
		ui.setNextItemWidth(ui.windowWidth()-25)
		local pos_slider3 = ui.slider("##Pos3", DriverEyes.pos3, -2, 2, "Back & Forward: %.3f", 1.1)
		ui.setNextItemWidth(ui.windowWidth()-25)
		local pitch_slider = ui.slider("##Pitch", DriverEyes.pitch, -5, 5, "Pitch: %.3f", 1.1)
		ui.setNextItemWidth(ui.windowWidth()-25)
		local yaw_slider = ui.slider("##Yaw", DriverEyes.yaw, -5, 5, "Yaw: %.3f")
		if pos_slider1 or pos_slider2 or pos_slider3 or pitch_slider or yaw_slider then
			DriverEyes.pos1 = pos_slider1
			DriverEyes.pos2 = pos_slider2
			DriverEyes.pos3 = pos_slider3
			posVec = vec3(DriverEyes.pos1, DriverEyes.pos2, DriverEyes.pos3)
			DriverEyes.pos = posVec
			DriverEyes.pitch = pitch_slider
			DriverEyes.yaw = yaw_slider
			ac.setOnboardCameraParams(0, ac.SeatParams(DriverEyes.pos, DriverEyes.pitch, DriverEyes.yaw))
		end
	end
end
--#endregion

--#region [[Keybind Old]]
local bruhtp = {
	v = -1, --key value for ac
	n = "", --key name for user
}
local showlespawnbutton = refbool(false)
local showlespawn = refbool(false)
local distance = 8
local function funnytp()
	if ui.button("reset") then
		ac.resetCar()
	end
	if ui.button("step back") then
		ac.takeAStepBack()
	end

	for i, j in pairs(ac.SpawnSet) do
		if ui.button(i) then
			physics.teleportCarTo(0, j)
		end
		ui.sameLine()
	end
	ui.newLine(15)
	ui.text("Teleport to Camera")
	--Toggles Button and starts the key listening
	if	ui.button(
		bruhtp.v == 0 and "Press a Key."
		or (bruhtp.v == -1 and "Click to Set Key" 
		or (bruhtp.v >= 1 and "Selected key: " .. bruhtp.n))) 
		then bruhtp.v = 0 end ui.sameLine()
	if ui.button("Reset Key") then
		bruhtp.v = -1
		bruhtp.n = "null"
	end ui.sameLine()

	ui.checkbox("show spawn",showlespawn)

	local tpdistance , tpchan = ui.slider("###tpdistance", distance, 1, 50, "Distance: %.0f Meters", 1)
	if tpchan then
		distance = tpdistance
	end

	--starts listening for keys when button is pressed
	if bruhtp.v == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic
			if ui.keyboardButtonDown(value) then
				time = 0.5
				bruhtp.v = value
				bruhtp.n = tostring(key)
			end
		end
	end
	local function DoTeleport()
		time = 0.5
		local teleportPoint = ac.getCameraPosition()
		local TeleportAngle = ac.getCameraForward()
		physics.setCarVelocity(0, vec3(0, 0, 0))
		physics.setCarPosition(0, teleportPoint + vec3(0,-1,0) + TeleportAngle * distance, -TeleportAngle * vec3(1,0,1))
	end
	if ui.keyboardButtonDown(bruhtp.v) then
		showlespawnbutton.value = true
	else
		showlespawnbutton.value = false
	end
	if ui.keyboardButtonReleased(bruhtp.v) then		
		if time <= 0 then
			DoTeleport()
		end
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
	ui.text("RemainingFuel:  	"..		math.round(RemainingFuel,2))
	ui.text("liters used:			"..	math.round(UsedFuel,2))
	--ui.text("DistanceTraveled:  "..		math.round(DistanceTraveled,2))
	ui.text("distance after pit:  "..	math.round(distance,2))
	ui.text("l/100km:   "..	math.round(LiterPer100KM,2))

	

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
		ui.tabItem("DriverHead", DriverHeadPos)
		ui.tabItem("Phy", funnytp)
		ui.tabItem("version", ver)
		ui.tabItem("fuul", Fueltest)

	end)
end

local thing = ac.dirname() .. "\\debug.png"
function script.draw3D()
	render.setBlendMode(render.BlendMode.Opaque)
	render.setCullMode(render.CullMode.ShadowsDouble)
	if showlespawn.value or showlespawnbutton.value then
		local campos = ac.getCameraPosition()
		local camlook = ac.getCameraForward()
		campos = vec3(campos + vec3(0, -1, 0) + camlook * distance)
		camlook = vec3(0, 1, 0) * camlook
		render.debugPlane(campos, camlook, rgbm(1, 1, 1, 1), 1)
	end
end


function script.update(dt)
	if time >= 0 then -- timer for anything to go
		time = time - dt
	end

--[[
	ac.debug("1 ds.battery",ds.battery)
	ac.debug("1 ds.batteryCharging",ds.batteryCharging)
	ac.debug("1 ds.gyroscope",ds.gyroscope)
	ac.debug("1 ds.accelerometer",ds.accelerometer)


	ac.debug("1 ds.touches[0].id",ds.touches[0].id)
	ac.debug("1 ds.touches[0].delta",ds.touches[0].delta)
	ac.debug("1 ds.touches[0].pos",ds.touches[0].pos)
	ac.debug("1 ds.touches[0].down",ds.touches[0].down)


	ac.debug("2 ds.touches[1].id",ds.touches[1].id)
	ac.debug("2 ds.touches[0].delta",ds.touches[1].delta)
	ac.debug("2 ds.touches[1].pos",ds.touches[1].pos)
	ac.debug("2 ds.touches[1].down",ds.touches[1].down)
--]]


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