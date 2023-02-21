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

local function ver()
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

local alpha 		= ac.getFolder(ac.FolderID.ACApps) 	.. "\\lua\\buller\\MINIMAP_MASK.dds"
local mapFilename 	= ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/map.png"
local debugtexture 	= ac.getFolder(ac.FolderID.ACApps) .. "\\lua\\buller\\debug.png"
local carico 		= ac.getFolder(ac.FolderID.ACApps) .. "\\lua\\buller\\MINIMAP_ICON_CAR.dds"
local mapParams 	= ac.INIConfig.load(ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/data/map.ini"):mapSection("PARAMETERS", 
{
	SCALE_FACTOR=0,
	X_OFFSET = 0, -- by providing default values script also specifies type, so that values can be parsed properly
	Z_OFFSET = 0,
	WIDTH = 600,
	HEIGHT = 600,
})



local function mapthing()

		ui.toolWindow("onjsfd2sdf",64,512,function ()


				local car = ac.getCar(0)
				
				posX = (car.position.x + mapParams.X_OFFSET) / mapParams.WIDTH
				posY = (car.position.z + mapParams.Z_OFFSET) / mapParams.HEIGHT

				ac.debug("1mapParams.X_OFFSET",mapParams.X_OFFSET)
				ac.debug("1mapParams.Z_OFFSET",mapParams.Z_OFFSET)
				ac.debug("2mapParams.WIDTH",mapParams.WIDTH)
				ac.debug("2mapParams.HEIGHT",mapParams.HEIGHT)
				ac.debug("3posX",posX)
				ac.debug("3posY",posY)
				--[[
				ui.drawImage(
					alpha,
					0,
					ui.windowSize(),
					rgbm.from0255(255, 255, 255,0.3),
					0,
					1,
					false
				)]]

				local rotationangle = 180 - math.deg(math.atan2(car.look.x, car.look.z))
				
				--ui.beginRotation()

				--[[
				ui.drawImageRounded(
					mapFilename, 
					6,
					ui.windowSize()-6,
					rgbm.colors.white, 
					vec2(posX - 0.5, posY - 0.5), 
					vec2(posX + 0.5, posY + 0.5), 
					math.huge
				)
				--]]
				--ui.endRotation(rotationangle+90)
				
				ui.renderTexture({
					filename = debugtexture,
					p1 = vec2(0, 0),
					p2 = vec2(512, 512)-64,
					color = rgbm.colors.white,
					uv1 = vec2(0, 0),
					uv2 = vec2(1, 1),
					blendMode = render.BlendMode.BlendAccurate
				})


				--[[
				ui.setCursor(-16)
				ui.image(carico,32,rgbm.colors.aqua,true)
				ui.setCursor(5)
				ui.image(carico, 32, rgbm.colors.black, true)
				--]]
		end)

end
-------------------------------------------------------------------------------------------------------------------------------------


local N20 = {
	UV1 = {
		X = 0,
		Y = 0,
	},
	UV2 = {
		X = 1,
		Y = 0,
	},
	UV3 = {
		X = 0.5,
		Y = 0.95,
	},
	UV4 = {
		X = 0,
		Y = 1,
},}

local toscale128 	= ac.DataLUT11():add(0,0):add(1,128)
local toscale256 	= ac.DataLUT11():add(0,0):add(1,256)
toscale128.extrapolate = true
toscale256.extrapolate = true


local N20Image 			= ac.dirname() .. "test25.dds" 
local test26 			= ac.dirname() .. "test26.dds" 
local test27 			= ac.dirname() .. "test27.dds" 
local METER_BACKING2 	= ac.dirname() .. "METER_BACKING2.dds" 


local n20lut = ac.DataLUT11():add(0,3.21):add(100,6.22)
n20lut.extrapolate=true
local trolled222 = 6.22

local function nosser()
	local UV1X, UV1XE = ui.slider("##UV1X", N20.UV1.X, 0, 1, "N20.UV1.X %.2f", 1)
	if UV1XE then
		N20.UV1.X = UV1X 
	end

	local UV1Y, UV1YE = ui.slider("##UV1Y", N20.UV1.Y, 0, 1, "N20.UV1.Y %.2f", 1)
	if UV1YE then
		N20.UV1.Y = UV1Y
	end

	local UV2X, UV2XE = ui.slider("##UV2X", N20.UV2.X, 0, 1, "N20.UV2.X %.2f", 1)
	if UV2XE then
		N20.UV2.X = UV2X 
	end

	local UV2Y, UV2YE = ui.slider("##UV2Y", N20.UV2.Y, 0, 1, "N20.UV2.Y %.2f", 1)
	if UV2YE then
		N20.UV2.Y = UV2Y 
	end


	local UV3X, UV3XE = ui.slider("##UV3X", N20.UV3.X, 0, 1, "N20.UV3.X %.2f", 1)
	if UV3XE then
		N20.UV3.X = UV3X 
	end

	local UV3Y, UV3YE = ui.slider("##UV3Y", N20.UV3.Y, 0, 1, "N20.UV3.Y %.2f", 1)
	if UV3YE then
		N20.UV3.Y = UV3Y
	end

	local UV4X, UV4XE = ui.slider("##UV4X", N20.UV4.X, 0, 1, "N20.UV4.X %.2f", 1)
	if UV4XE then
		N20.UV4.X = UV4X 
	end

	local UV4Y, UV4YE = ui.slider("##UV4Y", N20.UV4.Y, 0, 1, "N20.UV4.Y %.2f", 1)
	if UV4YE then
		N20.UV4.Y = UV4Y 
	end

	local rdm, rdme = ui.slider("##trolled222", trolled222, 0, 100, "trolled222 %.2f", 1)
	if rdme then
		trolled222 = rdm 
	end


	ui.toolWindow("onjsfd2sdf",vec2(256,256),512,function ()
		
		--[[
		ui.drawImageQuad(N20Image,
		--pos
		vec2(toscale256:get(N20.UV1.X),toscale128:get(N20.UV1.Y)),
		vec2(toscale256:get(N20.UV2.X),toscale128:get(N20.UV1.Y)),
		vec2(toscale256:get(N20.UV3.X),toscale128:get(N20.UV3.Y)),
		vec2(toscale256:get(N20.UV4.X),toscale128:get(N20.UV4.Y))
		,rgbm.colors.white,
		
		--uv1
		--vec2(0,0),
		vec2(N20.UV1.X,N20.UV1.Y),
		--uv2
		--vec2(1,0),
		vec2(N20.UV2.X,N20.UV2.Y),
		--uv3
		--vec2(1,1),
		vec2(N20.UV3.X,N20.UV3.Y),
		--uv4
		--vec2(0,1)
		vec2(N20.UV4.X,N20.UV4.Y))
		]]
		ui.pathArcTo(vec2(256,256),240,3.21,n20lut:get(trolled222),100)
		ui.pathStroke(rgbm(0.12, 0.6, 0.8,51),false,15)

		--ui.drawImage(METER_BACKING2, vec2(0,0), vec2(512,512), rgbm(0,0,0,0.2), nil,nil, true)

	end)

end

local nuke = false
function script.windowMain()
	if ui.checkbox("empty", nuke) then
		nuke = not nuke
	end
	if nuke then
		return
	end
	ui.tabBar("someTabBarID", bit.bor(ui.TabBarFlags.NoTooltip), function()
		ui.tabItem("ALLAH", rdm)
		ui.tabItem("Cammy", useless)
		ui.tabItem("Phy", funnytp)
		ui.tabItem("fov", fov)
		ui.tabItem("ver", ver)
		ui.tabItem("mapthing", mapthing)
		ui.tabItem("nosser", nosser)
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

function script.update(dt)
	if time >= 0 then -- timer for anything to go
		time = time - dt
	end
	--gripping()
end
