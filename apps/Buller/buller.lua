local time = 0
local oldme = ac.storage({	
	pos=vec3(),
	vel=vec3(),
	dir=vec3(),
	tp=0,
})

local eurostile = ui.DWriteFont("Eurostile","\\fonts")


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

local allah = ac.storage({
	pos = vec3(),
	pos1 = 0,
	pos2 = 0,
	pos3 = 0,
	pitch = 0,
	yaw = 0,
})
local function useless()
	local CameraDefault = ac.getOnboardCameraDefaultParams(0)
	ui.text("Default Camera Values")
	ui.text("Position :" .. tostring(CameraDefault.position))
	ui.text("Pitch    :" .. tostring(CameraDefault.pitch))
	ui.text("Yaw      :" .. tostring(CameraDefault.yaw))
	ui.newLine()
	local CameraCurrent = ac.getOnboardCameraParams(0)
	ui.text("Current Camera Values")
	ui.text("Position :" .. tostring(CameraCurrent.position))
	ui.text("Pitch    :" .. tostring(CameraCurrent.pitch))
	ui.text("Yaw      :" .. tostring(CameraCurrent.yaw))
	ui.newLine()

	if ui.button("Reset") then
		local pa, pb, pc = CameraDefault.position:unpack()
		allah.pos1 = pa
		allah.pos2 = pb
		allah.pos3 = pc
		posVec = vec3(allah.pos1, allah.pos2, allah.pos3)
		allah.pos = posVec
		allah.pitch = CameraDefault.pitch
		allah.yaw = CameraDefault.yaw
		ac.setOnboardCameraParams(0, ac.SeatParams(allah.pos, allah.pitch, allah.yaw))
	end

	ui.newLine()
	ui.text("New Position:")
	if ui.checkbox("Enable edit", deineMutter) then
		deineMutter = not deineMutter
	end
	if deineMutter then
		local pos_slider1 = ui.slider("##Pos1", allah.pos1, -2, 2, "Right & left: %.3f", 1.1)
		local pos_slider2 = ui.slider("##Pos2", allah.pos2, -2, 2, "Down & Up: %.3f", 1.1)
		local pos_slider3 = ui.slider("##Pos3", allah.pos3, -2, 2, "Back & Forward: %.3f", 1.1)
		local pitch_slider = ui.slider("##Pitch", allah.pitch, -5, 5, "Pitch: %.3f", 1.1)
		local yaw_slider = ui.slider("##Yaw", allah.yaw, -5, 5, "Yaw: %.3f")
		if pos_slider1 or pos_slider2 or pos_slider3 or pitch_slider or yaw_slider then
			allah.pos1 = pos_slider1
			allah.pos2 = pos_slider2
			allah.pos3 = pos_slider3
			posVec = vec3(allah.pos1, allah.pos2, allah.pos3)
			allah.pos = posVec
			allah.pitch = pitch_slider
			allah.yaw = yaw_slider
			ac.setOnboardCameraParams(0, ac.SeatParams(allah.pos, allah.pitch, allah.yaw))
		end
	end
end

local bruhtp = ac.storage({
	v = -1, --key value for ac
	n = "", --key name for user
})
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

local function fov()
	local getfov = ac.getCameraFOV()
	funnie = getfov
	local funnie, changed = ui.slider("##2cammy", funnie, 0.001, 50, "Fov: %.04f", 4)
	if changed then
		fovthing = funnie
		ac.setCameraFOV(fovthing)
	end
	ui.text("Speed: " .. tostring(math.floor(ac.getCar(0).speedKmh) .. " km/h"))
end

local function ver(dt)
	ui.text("Running CSP version: '"..ac.getPatchVersion().."' or also called '".. ac.getPatchVersionCode().."'")
end

local function randomkeybuttonpress()
	for key, value in pairs(ui.KeyIndex) do
		if ui.keyboardButtonDown(value) then
			ui.text(key .. ":".. value .. ",")
			ui.sameLine()
		end
	end
end 
------------------------------------------------------------------------------------------------------------------------------------
local lutpos = ac.DataLUT11():add(0,0):add(1,512)
lutpos.extrapolate=true
local sim = ac.getSim()
local teleportPoint = vec2(0.5, 0.5)

local alpha = ac.getFolder(ac.FolderID.ACApps) .. "\\lua\\buller\\MINIMAP_MASK.dds"
local mapFilename = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/map.png"
local mapParams = ac.INIConfig.load(ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/data/map.ini"):mapSection("PARAMETERS", {
	X_OFFSET = 0, -- by providing default values script also specifies type, so that values can be parsed properly
	Z_OFFSET = 0,
	WIDTH = 600,
	HEIGHT = 600,
})

local V = {
	UV1 = {
		X = 0,
		Y = 0,
	},
	UV2 = {
		X = 1,
		Y = 1,
		},
}
local mapSize = vec2(mapParams.WIDTH / mapParams.HEIGHT * 200, 175) * 2
-- local slider, changed = ui.slider("##UV1X", v.uv1.X, 0, 1, "%.3f", 1)


local testerrio = refbool(true)
local function mapthing()
	ui.checkbox("teststart",testerrio)

	local S_UV1X, C_UV1X = ui.slider("##UV1X", V.UV1.X, -1, 1, "UV1X %.3f", 1)
	if C_UV1X then V.UV1.X = S_UV1X end
	local S_UV1Y, C_UV1Y = ui.slider("##UV1Y", V.UV1.Y, -1, 1, "UV1Y %.3f", 1)
	if C_UV1Y then V.UV1.Y = S_UV1Y end

	local S_UV2X, C_UV2X = ui.slider("##UV2X", V.UV2.X, -1, 1, "UV2X %.3f", 1)
	if C_UV2X then V.UV2.X = S_UV2X end
	local S_UV2X, C_UV2X = ui.slider("##UV2Y", V.UV2.Y, -1, 1, "UV2Y %.3f", 1)
	if C_UV2X then V.UV2.Y = S_UV2X end

	if testerrio.value == true then
		ui.transparentWindow("onjsfd2sdf",12,512,function ()
			ui.setCursor(0)
			ui.childWindow("trollus", 512, true, bit.bor(ui.WindowFlags.AlwaysAutoResize,ui.WindowFlags.NoBackground), function ()
				local drawFrom = ui.getCursor()
				--ui.drawImage(mapFilename, drawFrom, drawFrom + mapSize,rgbm(1,1,1,0.3),0,1,true)
				
				local car = ac.getCar(0)
				
				posX = (car.position.x + mapParams.X_OFFSET) / mapParams.WIDTH
				posY = (car.position.z + mapParams.Z_OFFSET) / mapParams.HEIGHT
				
				ac.debug("me X Y",vec2(posX, posY))

				local rotationangle = 180 - math.deg(math.atan2(car.look.x, car.look.z))
				ui.beginRotation()
				--ui.drawImage(
				--	mapFilename,
				--	drawFrom+2,
				--	drawFrom + mapSize-2,
				--	rgbm.colors.white,
				--	vec2(posX - 0.2, posY - 0.2),
				--	vec2(posX + 0.2, posY + 0.2),
				--	true
				--)

				ui.drawImage(
					alpha,
					drawFrom+2,
					drawFrom + mapSize-2,
					rgbm.colors.white,
					0,
					1,
					true
				)

				ui.drawImageRounded(
					mapFilename, 
					drawFrom+8,
					drawFrom + mapSize-8,
					rgbm.colors.white, 
					vec2(posX - 0.2, posY - 0.2), 
					vec2(posX + 0.2, posY + 0.2), 
					math.huge
				)



				ui.endRotation(rotationangle+90)

				ui.drawCircleFilled(drawFrom + mapSize / 2, 5, rgbm(1, 0, 1, 1))


				--ui.drawCircleFilled(drawFrom + vec2(V.UV1.X, V.UV1.Y) * mapSize,4,rgbm.colors.white)
				--ui.drawCircleFilled(drawFrom + vec2(V.UV2.X, V.UV2.Y) * mapSize,4,rgbm.colors.black)
				--ui.drawCircleFilled(drawFrom + vec2(posX, 0) * mapSize,4,rgbm(1,0,1,1))
				--ui.drawCircleFilled(drawFrom + vec2(0, posY) * mapSize,4,rgbm(1,0,1,1))
				ui.dummy(mapSize)
				if ui.itemClicked() then
					teleportPoint = (ui.mouseLocalPos() - drawFrom) / mapSize
				end
			end)
		end)
	end
end
-------------------------------------------------------------------------------------------------------------------------------------


--############camber grip calculator


local function camberer()
	ui.setCursor(vec2(50,100))
	ui.text(floptimal)
	ui.setCursor(vec2(50,111))
	ui.text(flC)

	ui.setCursor(vec2(200,100))
	
	ui.text(froptimal)
	ui.setCursor(vec2(200,111))
	ui.text(frC)

	ui.setCursor(vec2(50,200))
	
	ui.text(rloptimal)
	ui.setCursor(vec2(50,211))
	ui.text(rlC)

	ui.setCursor(vec2(200,200))
	
	ui.text(rroptimal)
	ui.setCursor(vec2(200,211))
	ui.text(rrC)

end

--comber.frontleft 	flC
--comber.frontright 	frC
--comber.rearleft 	rlC
--comber.rearleft 	rrC


local dcamber0F = 9999
local dcamber1F = 9999
local dcamber0R = 9999
local dcamber1R = 9999
local LS_EXPYF = 9999
local LS_EXPYR = 9999

local tyredata = ac.INIConfig.carData(0, "tyres.ini")

tyreTable = {}
tyreTable[0] = {
	Check=0,
	dcamber0F 	= tyredata:get("FRONT", "DCAMBER_0", fallback),
	dcamber1F 	= tyredata:get("FRONT", "DCAMBER_1", fallback),
	dcamber0R 	= tyredata:get("REAR", "DCAMBER_0", fallback),
	dcamber1R 	= tyredata:get("REAR", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR", "LS_EXPY", fallback),
}

tyreTable[1] = {
	Check=1,
	dcamber0F	= tyredata:get("FRONT_1", "DCAMBER_0", fallback),
	dcamber1F	= tyredata:get("FRONT_1", "DCAMBER_1", fallback),
	dcamber0R	= tyredata:get("REAR_1", "DCAMBER_0", fallback),
	dcamber1R	= tyredata:get("REAR_1", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_1", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_1", "LS_EXPY", fallback),
}

tyreTable[2] = {
	Check=2,
	dcamber0F	= tyredata:get("FRONT_2", "DCAMBER_0", fallback),
	dcamber1F	= tyredata:get("FRONT_2", "DCAMBER_1", fallback),
	dcamber0R	= tyredata:get("REAR_2", "DCAMBER_0", fallback),
	dcamber1R	= tyredata:get("REAR_2", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_2", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_2", "LS_EXPY", fallback),
}

tyreTable[3] = {
	Check=3,
	dcamber0F	= tyredata:get("FRONT_3", "DCAMBER_0", fallback),
	dcamber1F	= tyredata:get("FRONT_3", "DCAMBER_1", fallback),
	dcamber0R	= tyredata:get("REAR_3", "DCAMBER_0", fallback),
	dcamber1R	= tyredata:get("REAR_3", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_3", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_3", "LS_EXPY", fallback),
}

tyreTable[4] = {
	Check=4,
	dcamber0F	= tyredata:get("FRONT_4", "DCAMBER_0", fallback),
	dcamber1F	= tyredata:get("FRONT_4", "DCAMBER_1", fallback),
	dcamber0R	= tyredata:get("REAR_4", "DCAMBER_0", fallback),
	dcamber1R	= tyredata:get("REAR_4", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_4", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_4", "LS_EXPY", fallback),
}

tyreTable[5] = {
	Check=5,
	dcamber0F	= tyredata:get("FRONT_5", "DCAMBER_0", fallback),
	dcamber1F	= tyredata:get("FRONT_5", "DCAMBER_1", fallback),
	dcamber0R	= tyredata:get("REAR_5", "DCAMBER_0", fallback),
	dcamber1R	= tyredata:get("REAR_5", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_5", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_5", "LS_EXPY", fallback),
}

tyreTable[6] = {
	Check=6,
	dcamber0F 	= tyredata:get("FRONT_6", "DCAMBER_0", fallback),
	dcamber1F 	= tyredata:get("FRONT_6", "DCAMBER_1", fallback),
	dcamber0R 	= tyredata:get("REAR_6", "DCAMBER_0", fallback),
	dcamber1R 	= tyredata:get("REAR_6", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_6", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_6", "LS_EXPY", fallback),
}

tyreTable[7] = {
	Check=7,
	dcamber0F 	= tyredata:get("FRONT_7", "DCAMBER_0", fallback),
	dcamber1F 	= tyredata:get("FRONT_7", "DCAMBER_1", fallback),
	dcamber0R 	= tyredata:get("REAR_7", "DCAMBER_0", fallback),
	dcamber1R 	= tyredata:get("REAR_7", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_7", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_7", "LS_EXPY", fallback),
}

tyreTable[8] = {
	Check=8,
	dcamber0F 	= tyredata:get("FRONT_8", "DCAMBER_0", fallback),
	dcamber1F 	= tyredata:get("FRONT_8", "DCAMBER_1", fallback),
	dcamber0R 	= tyredata:get("REAR_8", "DCAMBER_0", fallback),
	dcamber1R 	= tyredata:get("REAR_8", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_8", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_8", "LS_EXPY", fallback),
}

tyreTable[9] = {
	Check=9,
	dcamber0F 	= tyredata:get("FRONT_9", "DCAMBER_0", fallback),
	dcamber1F 	= tyredata:get("FRONT_9", "DCAMBER_1", fallback),
	dcamber0R 	= tyredata:get("REAR_9", "DCAMBER_0", fallback),
	dcamber1R 	= tyredata:get("REAR_9", "DCAMBER_1", fallback),
	LS_EXPYF 	= tyredata:get("FRONT_9", "LS_EXPY", fallback),
	LS_EXPYR 	= tyredata:get("REAR_9", "LS_EXPY", fallback),
}


local function optimalCamber(weightXfer, dcamber0, dcamber1, camberSplit)
	return math.rad(math.deg((2 * (1 - weightXfer) * dcamber1 * camberSplit - (1 - 2 * weightXfer) * dcamber0) / (2 * dcamber1)))
end
local function optimalmaybe(dcamber1, camber, dcamber0)
	return dcamber1 * camber ^ 2 - dcamber0 * camber + 1
end

local function gripping()
	--############camber grip calculator
	abc = nil
	if abc == nil or ac.getCar().compoundIndex ~= abc then
		abc = ac.getCar().compoundIndex
		for i = 0, 9 do
			if abc == i then
				dcamber0F = tonumber(tyreTable[i].dcamber0F[1])
				dcamber1F = tonumber(tyreTable[i].dcamber1F[1])
				dcamber0R = tonumber(tyreTable[i].dcamber0R[1])
				dcamber1R = tonumber(tyreTable[i].dcamber1R[1])
				LS_EXPYF = tonumber(tyreTable[i].LS_EXPYF[1])
				LS_EXPYR = tonumber(tyreTable[i].LS_EXPYR[1])
			end
		end
	end

	statewheel = ac.getCar().wheels
	local flL, frL, rlL, rrL = statewheel[0].load, statewheel[1].load, statewheel[2].load, statewheel[3].load
	flC, frC, rlC, rrC = statewheel[0].camber, statewheel[1].camber, statewheel[2].camber, statewheel[3].camber

	floptimal = optimalmaybe(dcamber1F, flC, dcamber0F)
	froptimal = optimalmaybe(dcamber1F, frC, dcamber0F)
	rloptimal = optimalmaybe(dcamber1F, rlC, dcamber0F)
	rroptimal = optimalmaybe(dcamber1F, rrC, dcamber0F)

	--############camber grip calculator
end
--############camber grip calculator


local showlenam = true
local toggle = false

local function newnames()
	-- [[
	if toggle == ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone) then
		return
	end

	if toggle == false then
		toggle = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
	end

	if ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone) == true then
		showlenam = not showlenam
	end

	if showlenam == true then
		ui.toast(ui.Icons.Bug, "Names Enabled")
	else
		ui.toast(ui.Icons.Bug, "Names Disabled")
	end
	toggle = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
	--]]
end

local nuke = false
function script.windowMain()
	if ui.checkbox("empty", nuke) then
		nuke = not nuke
	end
	if nuke then
		return
	end
	ui.tabBar("someTabBarID", bit.bor(ui.TabBarFlags.NoTooltip, ui.TabBarFlags.Reorderable), function()
		ui.tabItem("ALLAH", rdm)
		ui.tabItem("Cammy", useless)
		ui.tabItem("Phy", funnytp)
		ui.tabItem("fov", fov)
		ui.tabItem("ver", ver)
		ui.tabItem("mapthing", mapthing)
		ui.tabItem("camber", camberer)
	end)
end

function script.draw3D()
	if showlespawn.value or showlespawnbutton.value then
		render.setBlendMode(render.BlendMode.Opaque)
		render.setCullMode(render.CullMode.ShadowsDouble)
		local campos = ac.getCameraPosition()
		local camlook = ac.getCameraForward()
		campos = vec3(campos + vec3(0, -1, 0) + camlook * distance)
		camlook = vec3(0, 1, 0) * camlook
		render.debugPlane(campos, camlook, rgbm(1, 1, 1, 1), 1)
	end
end

nameLutForCar = ac.DataLUT11():add(100, 1):add(10, 15)
nameLutForCar.extrapolate = true

nameLutForCam = ac.DataLUT11():add(150, 1):add(20, 25)
nameLutForCam.extrapolate = true

function script.fullscreenUI()
	if showlenam == true then
		local sim = ac.getSim()
		local focusedCar = ac.getCar(sim.focusedCar)
		local campos = sim.cameraPosition

		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			if sim.isFreeCameraOutside == true then
				local DistanceBetweenMeAndYou = math.distance(car.position,campos)
				if DistanceBetweenMeAndYou < 150 then	
					local screenpos = ui.projectPoint(car.position + vec3(0,2.5,0))
					local textsize = ui.measureDWriteText(driverName,nameLutForCam:get(DistanceBetweenMeAndYou))
					ui.drawRectFilled(screenpos - (textsize/1.9) ,screenpos + (textsize/1.9) , rgbm(0,0,0,0.08))
					ui.dwriteDrawText(driverName, nameLutForCam:get(DistanceBetweenMeAndYou), screenpos-(textsize/2), rgbm(0,1,0,0.9))
				end
				return
			end

			if car.isConnected --[[and not car.isAIControlled]] and not string.find(driverName, "Traffic") and not string.find(driverName, ac.getDriverName(sim.focusedCar)) then
				local DistanceBetweenMeAndYou = math.distance(car.position,focusedCar.position)
				if DistanceBetweenMeAndYou < 100 then

					local screenpos = ui.projectPoint(car.position + vec3(0,2.3,0))
					local textsize = ui.measureDWriteText(driverName,nameLutForCar:get(DistanceBetweenMeAndYou))
					
					ui.drawRectFilled(screenpos - (textsize/1.9) ,screenpos + (textsize/1.9) , rgbm(0,0,0,0.08))
					ui.dwriteDrawText(driverName, nameLutForCar:get(DistanceBetweenMeAndYou), screenpos-(textsize/2), rgbm(0,1,0,0.9))
				end
			end
		end
	end
end

local function respawnfixLOL()
	if ac.isKeyDown(ac.KeyIndex.LeftControl) and ac.isKeyDown(ac.KeyIndex.B) then
		physics.teleportCarTo(0, ac.SpawnSet.Pits)
	end
end

function script.update(dt)
	if time >= 0 then -- timer for anything to go
		time = time - dt
	end
	gripping()
	newnames()
	respawnfixLOL()

	trolled = ac.getDualSense(4).touches
	ac.debug("23", stringify(trolled[0]))
end
