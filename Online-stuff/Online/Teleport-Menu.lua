local timer = 0
CameraKey = ac.storage({
	v = -1, --key value for ac
	n = "", --key name for user
	x = 0, --x pos for overlay pos
	y = 0, --x pos for overlay pos
})

--Menu
local function Teleportation()
	--showing timer seems logical to me here
	ui.text("Cooldown: " .. math.round(timer, 1))

	ui.tabBar("Atabbar", function() --A TAB BAR
		ui.tabItem("Car to Camera", keybindtp) --ayo
		ui.tabItem("Car to Car", cartocar) --piss
		ui.tabItem("Map", Mapthing)
	end)
end

function keybindtp() --first tab
	ui.text("Teleport to Camera")
	--Toggles Button and starts the key listening
	if
		ui.button(
			CameraKey.v == 0 and "Press a Key."
				or (CameraKey.v == -1 and "Click to Set Key" or (CameraKey.v >= 1 and "Selected key: " .. CameraKey.n))
		)
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
				if timer <= 0.5 then
					timer = 0.5
				else
				end --anti "cooldown" bypass LOL
				CameraKey.v = value
				CameraKey.n = tostring(key)
			end
		end
	end
end

function cartocar() --just straight up ripped from teleport to car cause it seems modular af LOL
	ui.text("Will teleport you behind the selected car.")
	ui.text("Select car to teleport to:")
	ui.childWindow("##drivers", vec2(ui.availableSpaceX(), 120), function()
		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			if car.isConnected and not car.isAIControlled and not string.find(driverName, "Traffic") then
				if ui.selectable(driverName, selectedCar == car) then
					selectedCar = car
				end
				if ui.button("Teleport") and selectedCar and timer <= 0 then -- check if car selected/button pressed/timer above 0
					timer = 3
					local dir = selectedCar.look
					physics.setCarVelocity(0, vec3(0, 0, 0))
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
local padding = vec2(30, 50)
local offsets = -padding * 0.5
local ts = 10

if ac.getPatchVersionCode() >= 2000 then
	local shitter = ac.getFolder(ac.FolderID.ContentTracks) .. '/' .. ac.getTrackFullID('/') .. '/map_mini.png' --for srp only lol 
	map = ac.getFolder(ac.FolderID.ContentTracks) .. '/' .. ac.getTrackFullID('/') .. '/map.png'
	current_map = map
	if io.exists(shitter) then
		current_map = shitter
		ui.decodeImage(shitter)
	end
	ui.decodeImage(map)
	--ini stuff size
	local ini = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/data/map.ini"
	for a, b in ac.INIConfig.load(ini):serialize():gmatch("([_%a]+)=([-%d.]+)") do -- ◀ i dont understand the "([_%a]+)=([-%d.]+)"
		mapstuff[a] = tonumber(b)
	end
	image_size = ui.imageSize(map)
	config_offset = vec2(mapstuff.X_OFFSET, mapstuff.Z_OFFSET)
end

function Mapthing()
	ui.text("Press Spacebar while on map to teleport the camera")
	map_scale = math.min((ui.windowWidth() - padding.x) / image_size.x, (ui.windowHeight() - padding.y) / image_size.y)
	size = ui.imageSize(current_map) * map_scale
	config_scale = map_scale / mapstuff.SCALE_FACTOR

	ui.drawImage(current_map, -offsets, -offsets + size)

	pos3 = ac.getCameraPosition()
	pos2:set(pos3.x, pos3.z):add(config_offset):scale(config_scale):add(-offsets)


	dir3 = ac.getCameraForward()
	dir2 = vec2(dir3.x, dir3.z):normalize()
	dir2x:set(dir3.z, -dir3.x):normalize()

	ui.drawTriangleFilled(
		pos2 + dir2 * ts,
		pos2 - dir2 * ts - dir2x * ts * 0.75,
		pos2 - dir2 * ts + dir2x * ts * 0.75,
		rgbm(155, 0, 155, 2255)
	)

	if ui.keyPressed(ui.Key.Space) and ui.windowHovered() then
		local camerapos = (ui.mouseLocalPos() + offsets) / config_scale - config_offset
		local raycast = physics.raycastTrack(vec3(camerapos.x, 2000, camerapos.y), vec3(0, -1, 0), 3000)
		local cameraheight = 2000 - raycast + 3
		if raycast ~= -1 then
			ac.setCurrentCamera(ac.CameraMode.Free)
			ac.setCameraPosition(vec3(camerapos.x, cameraheight, camerapos.y))
		end
	end
end

local function DoTeleport() --simplest teleport function ever
	local teleportPoint = ac.getCameraPosition()
	local TeleportAngle = ac.getCameraForward()
	physics.setCarPosition(0, teleportPoint, -TeleportAngle)
	physics.setCarVelocity(0, vec3(0, 0, 0))
end

function script.update(dt)
	if timer >= 0 then -- timer for anything to go
		timer = timer - dt
	end

	if ui.keyboardButtonPressed(CameraKey.v) and timer <= 0 then
		DoTeleport()
		timer = 3
	end
end

function script.drawUI()
	if OverlayTimerKey == true then
		ui.transparentWindow("Keyandabindandacooldown", vec2(-15, -5), vec2(150, 150), false, function()
			ui.text("Key: " .. CameraKey.n .. "\nCooldown: " .. math.round(timer, 1))
		end)
	end
end

ui.registerOnlineExtra(ui.Icons.Compass, "Manual Teleport Menu", nil, Teleportation, nil, ui.OnlineExtraFlags.Tool)