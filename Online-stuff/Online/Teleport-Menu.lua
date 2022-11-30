CameraKey = ac.storage({
	v = -1, --key value for ac
	n = "", --key name for user
	showtp = false,
})

local timer = {
	running = 0,	--we move length/blength into here
	length = 3,		--the normal length after teleporting
	blength = 0.5,	--length after setting a button
}

local tpdistance = 8



--Menu
local function Teleportation()
	--showing timer seems logical to me here
	ui.text("Cooldown: " .. math.round(timer.running, 1))

	ui.tabBar("Atabbar", function() --A TAB BAR
		ui.tabItem("Car to Camera", keybindtp) --ayo
		ui.tabItem("Car to Car", cartocar) --piss
		ui.tabItem("Map", Mapthing)
	end)
end


function keybindtp() --first tab
	ui.text("Teleport to Camera")

	local distanceslider , tpbool = ui.slider("###tpdistance", tpdistance, 0, 20, "TP Distance: %.0f Meters", 1)
	if tpbool then
		tpdistance = distanceslider
	end

	if ui.checkbox("Show TP destination when holding down TP button", CameraKey.showtp) then
		CameraKey.showtp = not CameraKey.showtp
	end

	--Toggles Button and starts the key listening
	if
		ui.button(
			CameraKey.v == 0 and "Press a Key."
			or (CameraKey.v == -1 and "Click to Set Key" 
			or (CameraKey.v >= 1 and "Selected key: " .. CameraKey.n)))
	then
		CameraKey.v = 0
	end
	ui.sameLine() --makes 🔼🔽 same line
	--resets the key
	if ui.button("Reset Key") then
		CameraKey.v = -1
		CameraKey.n = "null"
	end
	--shows cooldown timer via script.drawUI
	if ui.checkbox("Show Cooldown and Key", OverlayTimerKey) then
		OverlayTimerKey = not OverlayTimerKey
	end

	--starts listening for keys when button is pressed
	if CameraKey.v == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic
			if ui.keyboardButtonDown(value) then
				if timer.running <= 0.5 then
					timer.running = timer.blength
				else
				end --anti "cooldown" bypass LOL
				CameraKey.v = value
				CameraKey.n = tostring(key)
			end
		end
	end
end

function cartocar() --just straight up ripped from teleport to car cause it seems modular af LOL
	ui.text("Will teleport you 8~ Meters behind the selected car.")
	ui.text("Select car to teleport to:")
	ui.childWindow("##drivers", vec2(ui.availableSpaceX(), 120), function()
		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			if car.isConnected and not car.isAIControlled and not string.find(driverName, "Traffic") then
				if ui.selectable(driverName, selectedCar == car) then
					selectedCar = car
				end
				if ui.button("Teleport") and selectedCar and timer.running <= 0 then -- check if car selected/button pressed/timer above 0
					timer.running = timer.length
					local dir = selectedCar.look
					physics.setCarVelocity(0, vec3(0, 0, 0)) --reset velocity
					-- spawn 8 meters behind, add 0.1 meter height to avoid falling through the map
					physics.setCarPosition(0, selectedCar.position + vec3(0, 0.1, 0) - dir * 8, -dir)
				end
			end
		end
	end)
end

-- stuff with map
local mapstuff = {}
local pos3, dir3, pos2, dir2, dir2x = vec3(), vec3(), vec2(), vec2(), vec2()
local padding = vec2(30*3, 50*3)
local offsets = -padding * 0.5
local ts = 10
local first = true

if ac.getPatchVersionCode() >= 2000 then
	map = ac.getFolder(ac.FolderID.ContentTracks) .. '/' .. ac.getTrackFullID('/') .. '/map.png'
	current_map = map
	ui.decodeImage(map)

	--ini stuff size
	ini = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/data/map.ini"
	for a, b in ac.INIConfig.load(ini):serialize():gmatch("([_%a]+)=([-%d.]+)") do -- ◀ i dont understand the "([_%a]+)=([-%d.]+)"
		mapstuff[a] = tonumber(b)
	end
	image_size = ui.imageSize(map)
	config_offset = vec2(mapstuff.X_OFFSET, mapstuff.Z_OFFSET)
end

function Mapthing()
	ui.text([[
Press Spacebar while on map to teleport the Camera | You can Drag and zoom into the map. (zoom completely out of it bugged)
Green = Camera/You
Red = other users.]])
	ui.childWindow("##mapforcamera", vec2(ui.availableSpaceX(), ui.availableSpaceY()),
	function()
		if ac.getPatchVersionCode() < 2000 then ui.text("only above ver 2000 it work") return end

		if first then --set the map scale, if not in here it will keep the size and not scale with scroll wheel
			map_scale = math.min((ui.windowWidth() - padding.x) / image_size.x, (ui.windowHeight() - padding.y) / image_size.y)
			config_scale = map_scale / mapstuff.SCALE_FACTOR
			size = image_size * map_scale
			if ui.isImageReady(current_map) then
				first = false
			end
		end

		ui.drawImage(current_map, -offsets, -offsets + size)

		if ui.windowHovered() then --zoom&drag
			if ac.getUI().mouseWheel ~= 0 then
			  if 
			  (	ac.getUI().mouseWheel < 0 and (size.x + padding.x > ui.windowWidth() and size.y + padding.y > ui.windowHeight())) 
				or ac.getUI().mouseWheel > 0 then
				local old = size
				map_scale = map_scale * (1 + ac.getUI().mouseWheel * 0.15)
				size = ui.imageSize(current_map) * map_scale
				config_scale = map_scale / mapstuff.SCALE_FACTOR
				offsets = (offsets + (size - old) * (offsets + ui.mouseLocalPos()) / old)
			  else
				offsets = -padding * 0.5
				map_scale = math.min((ui.windowWidth() - padding.x) / image_size.x,(ui.windowHeight() - padding.y) / image_size.y)
				size = ui.imageSize(current_map) * map_scale
				config_scale = map_scale / mapstuff.SCALE_FACTOR
			  end
			end
		  end

		--other ppl pos
		for i = ac.getSim().carsCount - 1, 1, -1 do --draw stuff on map
			local car = ac.getCar(i)
			if car.isConnected and (not car.isHidingLabels) then
				local pos3 = car.position
				local dir3 = car.look

				pos2:set(pos3.x, pos3.z):add(config_offset):scale(config_scale):add(-offsets)
				dir2:set(dir3.x, dir3.z) -- = vec2(dir3.x, dir3.z)
				dir2x:set(dir3.z, -dir3.x)
				ui.drawTriangleFilled(
					pos2 + dir2 * ts,
					pos2 - dir2 * ts - dir2x * ts * 0.75,
					pos2 - dir2 * ts + dir2x * ts * 0.75,
					rgbm(255,0,0,255))
				ui.dwriteDrawText(ac.getDriverName(i),10,pos2 + vec2(25,5) - ui.measureText(ac.getDriverName(i)) * 0.5,rgbm.colors.	white)
			end
		end

		--camera pos and local user 
		pos3 = ac.getCameraPosition()
		pos2:set(pos3.x, pos3.z):add(config_offset):scale(config_scale):add(-offsets)
		dir3 = ac.getCameraForward()
		dir2 = vec2(dir3.x, dir3.z):normalize()
		dir2x:set(dir3.z, -dir3.x):normalize()
		ui.drawTriangleFilled(
			pos2 + dir2 * ts,
			pos2 - dir2 * ts - dir2x * ts * 0.75,
			pos2 - dir2 * ts + dir2x * ts * 0.75,
			rgbm(0, 255, 0, 255))
		if ui.keyPressed(ui.Key.Space) and ui.windowHovered() then
			local camerapos = (ui.mouseLocalPos() + offsets) / config_scale - config_offset
			local raycast = physics.raycastTrack(vec3(camerapos.x, 2000, camerapos.y), vec3(0, -1, 0), 3000)
			local cameraheight = 2000 - raycast + 3
			if raycast ~= -1 then
				ac.setCurrentCamera(ac.CameraMode.Free)
				ac.setCameraPosition(vec3(camerapos.x, cameraheight, camerapos.y))
			end
		end

		ui.invisibleButton('###mapforcamera4242', ui.windowSize())
		if ui.mouseDown() and ui.itemHovered() then offsets = offsets - ui.mouseDelta() end
	end)
end

local function DoTeleport() --simplest teleport function ever
	local teleportPoint = ac.getCameraPosition()
	local TeleportAngle = ac.getCameraForward()
	physics.setCarVelocity(0, vec3(0, 0, 0))
	physics.setCarPosition(0, teleportPoint + vec3(0,-1,0) + TeleportAngle * tpdistance, -TeleportAngle * vec3(1,0,1))
end

function script.update(dt)
	if timer.running >= 0 then -- timer for anything to go
		timer.running = timer.running - dt
	end

	if ui.keyboardButtonReleased(CameraKey.v) and timer.running <= 0 then
		DoTeleport()
		timer.running = timer.length
	end
end

function script.drawUI()
	if OverlayTimerKey == true then
		ui.transparentWindow("Keyandabindandacooldown", vec2(-15, -5), vec2(150, 150), false, function()
			ui.text("Key: " .. CameraKey.n .. "\nCooldown: " .. math.round(timer.running, 1))
		end)
	end
end

function script.draw3D()
	if CameraKey.showtp and ui.keyboardButtonDown(CameraKey.v) then
	render.setBlendMode(render.BlendMode.Opaque)
	render.setCullMode(render.CullMode.Wireframe)
	render.setDepthMode(render.DepthMode.ReadOnlyLessEqual)
		local campos = ac.getCameraPosition()
		local camlook = ac.getCameraForward()
		campos = vec3(campos + vec3(0,-1,0) + camlook * tpdistance)
		camlook = vec3(0, 1, 0)*camlook
		--physics.setCarVelocity(0, vec3(0, 0, 0))
		--physics.setCarPosition(0, campos + vec3(0,-1,0) + camlook * 6, -camangle)
		render.debugPlane(campos,camlook,rgbm(1, 1, 1, 1),1)
	end
end


ui.registerOnlineExtra(	ui.Icons.Compass,
						"Manual Teleport Menu",
						nil,
						Teleportation,
						nil,
						ui.OnlineExtraFlags.Tool,
						ui.WindowFlags.NoScrollWithMouse)