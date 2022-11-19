local timer = 0
CameraKey = ac.storage({
	v = -1, --key value for ac
	n = "", --key name for user
	x = 0, --x pos for overlay pos
	y = 0, --x pos for overlay pos
})

--Menu
local function Teleportation💀()
	--showing timer seems logical to me here
	ui.text("Cooldown: " .. math.round(timer, 1))

	ui.tabBar("Atabbar", function() --A TAB BAR
		ui.tabItem("Car to Camera", keybindtp) --ayo
		ui.tabItem("Car to Car", cartocar) --piss
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

	mapthing()
end

local mapready = true
local asd = {}
function mapthing()
	if ac.getPatchVersionCode() >= 2000 then
		map1 = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/map_mini.png"
		map = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/map.png"
		current_map = map
		if io.exists(map1) then
			current_map = map1
			ui.decodeImage(map1)
		end
		ui.decodeImage(map)
		ini = ac.getFolder(ac.FolderID.ContentTracks) .. "/" .. ac.getTrackFullID("/") .. "/data/map.ini"
		for a, b in ac.INIConfig.load(ini):serialize():gmatch("([_%a]+)=([-%d.]+)") do
			asd[a] = tonumber(b)
		end
		image_size = ui.imageSize(map)
		config_offset = vec2(asd.X_OFFSET, asd.Z_OFFSET)
	end
	ui.pushClipRect(0, ui.windowSize()) --background
	if ac.getPatchVersionCode() < 2000 then
		ui.text(versionerror)
		return
	end
	ui.invisibleButton()

	if mapready then
		map_scale =
			math.min((ui.windowWidth() - 20) / image_size.x, (ui.windowHeight() - 20) / image_size.y)

		config_scale = map_scale / asd.SCALE_FACTOR
		size = image_size * map_scale

		if ac.getSim().isOnlineRace then --teleport config
			onlineExtras = ac.INIConfig.onlineExtras()
			teleports, teleports1 = {}, {}
			for a, b in onlineExtras:iterateValues("TELEPORT_DESTINATIONS", "POINT") do
				n = tonumber(b:match("%d+")) + 1
				if teleports[n] == nil then
					for i = #teleports + 1, n do
						if teleports[i] == nil then
							teleports[i] = {}
						end
					end
				end
				ac.debug("highest index", #teleports)

				if b:match("POS") ~= nil then
					teleports[n]["POS"] = onlineExtras:get("TELEPORT_DESTINATIONS", b, vec3())
				elseif b:match("HEADING") ~= nil then
					teleports[n]["HEADING"] = onlineExtras:get("TELEPORT_DESTINATIONS", b, 0)
				elseif b:match("GROUP") ~= nil then
					teleports[n]["GROUP"] = onlineExtras:get("TELEPORT_DESTINATIONS", b, "group")
				else
					teleports[n]["POINT"] = onlineExtras:get("TELEPORT_DESTINATIONS", b, "name")
				end
				teleports[n]["N"] = n
			end

			for i = 1, #teleports do
				if teleports[i]["POINT"] ~= nil then
					teleports1[#teleports1 + 1] = teleports[i]
				end
			end
		end

		if ui.isImageReady(current_map) then
			mapready = false
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

ui.registerOnlineExtra(ui.Icons.Compass, "Manual Teleport Menu", nil, Teleportation💀, nil, ui.OnlineExtraFlags.Tool)
