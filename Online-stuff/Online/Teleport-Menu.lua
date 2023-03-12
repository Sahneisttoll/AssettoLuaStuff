Settings = ac.storage({
	KeyValue = 999, --key value for ac
	KeyName = "", --key name for user
	TPtoCam = false,
	ShowKeyTP = false,
	tpDistance = 8,
	SpectatePlayer = false,
	MousetoTrackRays = false,
	MousetoTrackRays_updates = "500",
	MousetoTrackRays_Chord_keyValue = 999,
	MousetoTrackRays_Chord_KeyName = "",
	MousetoTrackRays_pos_keyValue = 999,
	MousetoTrackRays_pos_KeyName = "",
	MousetoTrackRays_dir_keyValue = 999,
	MousetoTrackRays_dir_KeyName = "",
	MousetoTrackRays_TP_keyValue = 999,
	MousetoTrackRays_TP_KeyName = "",
})

local timer = {
	running = 0,	--we move length/blength into here
	length = 0,		--the normal length after teleporting
	blength = 0.5,	--length after setting a button
}

--#region [Menu]
local function Teleportation()
	--showing timer seems logical to me here
	ui.text("Cooldown: " .. math.round(timer.running, 1))

	ui.tabBar("Atabbar", function()
		ui.tabItem("Car to Camera", KeybindTP_UI)
		ui.tabItem("Mouse to Track", ToTrackWithRotation_UI) 
		ui.tabItem("Car to Car", CartoCar_UI)
		ui.tabItem("Map", MapTest)
	end)
end
--#endregion

--#region [TP to Camera]

function KeybindTP_UI() --first tab
	ui.text("Teleport to Camera")

	if ui.checkbox("Enalbe", Settings.TPtoCam) then
		Settings.TPtoCam = not Settings.TPtoCam
	end


	local distanceslider , tpbool = ui.slider("###tpdist", Settings.tpDistance, 0, 20, "TP Distance: %.0f Meters", 1)
	if tpbool then
		Settings.tpDistance = distanceslider
	end

	if ui.checkbox("Show TP destination when holding down TP button", Settings.ShowKeyTP) then
		Settings.ShowKeyTP = not Settings.ShowKeyTP
	end

	--Toggles Button and starts the key listening
	if
		ui.button(
			Settings.KeyValue == 0 and "Press a Key."
			or (Settings.KeyValue == 999 and "Click to Set Key" 
			or (Settings.KeyValue >= 1 and "Selected key: " .. Settings.KeyName)))
	then
		Settings.KeyValue = 0
	end
	ui.sameLine() --makes 🔼🔽 same line
	--resets the key
	if ui.button("Reset Key") then
		Settings.KeyValue = 999
		Settings.KeyName = "null"
	end
	--shows cooldown timer via script.drawUI
	if ui.checkbox("Show Cooldown and Key", OverlayTimerKey) then
		OverlayTimerKey = not OverlayTimerKey
	end

	--starts listening for keys when button is pressed
	if Settings.KeyValue == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic
			if ui.keyboardButtonDown(value) then
				if timer.running <= 0.5 then
					timer.running = timer.blength
				else
				end --anti "cooldown" bypass LOL
				Settings.KeyValue = value
				Settings.KeyName = tostring(key)
			end
		end
	end
end

function TPtoCam_Update()
	if Settings.TPtoCam == true then
		if ui.keyboardButtonReleased(Settings.KeyValue) and timer.running <= 0 then
			local teleportPoint = ac.getCameraPosition()
			local TeleportAngle = ac.getCameraForward()
			physics.setCarVelocity(0, vec3(0, 0, 0))
			physics.setCarPosition(0, teleportPoint + vec3(0,-1,0) + TeleportAngle * Settings.tpDistance, -TeleportAngle * vec3(1,0,1))
			timer.running = timer.length
		end
	end
end

function TPtoCam_draw3D()
	if Settings.TPtoCam == true then
		if Settings.ShowKeyTP and ui.keyboardButtonDown(Settings.KeyValue) then
			render.setBlendMode(render.BlendMode.Opaque)
			render.setCullMode(render.CullMode.Wireframe)
			render.setDepthMode(render.DepthMode.ReadOnlyLessEqual)
			local campos = ac.getCameraPosition():clone()
			local camlook = ac.getCameraForward():clone():normalize()
			local camside = ac.getCameraSide():clone()
			campos:set(vec3(campos + vec3(0,-1,0) + camlook * Settings.tpDistance))
	
			local FrontBack = vec3()
			local Sides = vec3()
			local Top_Left = vec3()
			local Top_Right = vec3()
			local Rear_Left = vec3()
			local Rear_Right= vec3()
			local LookArrow = vec3()
	
			FrontBack	:set((camlook):mul(vec3(1, 0, 1))):scale(ac.getCar(0).aabbSize.x):normalize():scale(1.75)
			Sides		:set(camside):scale(ac.getCar(0).aabbSize.x):scale(0.5)
			Top_Left	:set(campos):add( FrontBack - Sides)
			Top_Right	:set(campos):add( FrontBack + Sides)
			Rear_Left	:set(campos):add(-FrontBack - Sides)
			Rear_Right	:set(campos):add(-FrontBack + Sides)
			render.debugLine(Top_Left,Top_Right,rgbm(1, 1, 1, 1))
			render.debugLine(Rear_Left,Rear_Right,rgbm(1, 1, 1, 1))
			render.debugLine(Top_Left,Rear_Left,rgbm(1, 1, 1, 1))
			render.debugLine(Top_Right,Rear_Right,rgbm(1, 1, 1, 1))
			render.debugLine(Top_Left, Rear_Right, rgbm(1, 1, 1, 1))
			render.debugLine(Top_Right, Rear_Left, rgbm(1, 1, 1, 1))
	
			LookArrow:set(camlook):mul(vec3(1,0,1)):normalize():scale(2.5)
			render.debugArrow(campos+vec3(0,1,0),campos,rgbm(1, 1, 1, 1),2)
			render.debugArrow(campos,campos+LookArrow,rgbm(1, 1, 1, 1),2)
		end
	end
end
--#endregion

--#region [Car to Car] --physics stuff works in ui shit too so lol
function CartoCar_UI()
	ui.text("Will teleport you 8~ Meters behind the selected car.")
	if ui.checkbox("Spectate Player on Click",Settings.SpectatePlayer) then Settings.SpectatePlayer = not Settings.SpectatePlayer end
	ui.text("Select car to teleport to:")
	ui.childWindow("##drivers", vec2(ui.availableSpaceX(), 120), function()
		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			if car.isConnected and not car.isAIControlled and not string.find(driverName, "Traffic") then
				if ui.selectable(driverName, selectedCar == car) then
					selectedCar = car
					if Settings.SpectatePlayer == true then
						ac.focusCar(i)
					end
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
--#endregion

--#region [Map stuff, experimental bad]
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

function MapTest()
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
--endregion

--#region [Raycast Mouse thing]
local player = ac.getCar(0)
local sim = ac.getSim()
local tp_realDirection = mat4x4()
local DriveableColor = rgbm(3, 0, 0, 1)

local tp_position = vec3()
function getPosfromMouse()
    local ray = nil
	local time = math.floor(sim.time)
	local NegateMuchupdate = time % Settings.MousetoTrackRays_updates
	if NegateMuchupdate <= 25 then --10ms time frame for an update
		ac.debug("What","pos")
        ray = render.createMouseRay()
        tp_position:set(ray.dir * ray:track() + ray.pos)
		Driveable = rgbm(3, 0, 0, 1) -- default red when its not driveable
		if ray:physics() ~= -1 then -- makes it green when you selected a driveable mesh
			Driveable = rgbm(0, 5, 0, 1)
			ray:physics(tp_position)
		end
	end
end

local tp_direction_calc = vec3()
function getDirFromMouse()
    local ray = nil
	local time = math.floor(sim.time)
	local NegateMuchupdate = time % Settings.MousetoTrackRays_updates
	if NegateMuchupdate <= 25 then --10ms time frame for an update
		ac.debug("What","dir")
        ray = render.createMouseRay()
        tp_direction_calc:set(ray.dir * ray:track() + ray.pos)
	end
end

local function lookAt(origin,target)
	if origin ~= nil and target ~= nil then
		local zaxis = vec3():add(target - origin):normalize()
		local xaxis = zaxis:clone():cross(vec3(0, 1, 0)):normalize()
		local yaxis = xaxis:clone():cross(zaxis):normalize()
		local viewMatrix = mat4x4(
		vec4(xaxis.x, xaxis.y, xaxis.z, -xaxis:dot(origin)),
		vec4(yaxis.x, yaxis.y, yaxis.z, -yaxis:dot(origin)),
		vec4(zaxis.x, zaxis.y, zaxis.z, -zaxis:dot(origin)),
		vec4(0, 1, 0, 1))
		-- viewMatrix.look
		-- viewMatrix.side
		return viewMatrix
	end
end

function ToTrackWithRotation_UI()
	if ui.checkbox("Enable Mouse to Track Rays TP", Settings.MousetoTrackRays) then
		Settings.MousetoTrackRays = not Settings.MousetoTrackRays
	end
	ui.text("Updates Per ms (Rays are expensive) 1000ms = 1s")
	ui.setNextItemWidth(ui.windowWidth()-50)
	local UpdateperMS, UpdateperMSEnabled = ui.slider("##Upms",Settings.MousetoTrackRays_updates,1,2500,"%.0fms",1)
	if UpdateperMSEnabled then
		Settings.MousetoTrackRays_updates = UpdateperMS 
	end
	ui.newLine(-15)
	ui.text("Chord Key")
	--Toggles Button and starts the key listening
	if
		ui.button(
			Settings.MousetoTrackRays_Chord_keyValue == 0 and "Press a Key."
			or (Settings.MousetoTrackRays_Chord_keyValue == 999 and "Click to Chord Set Key"
			or (Settings.MousetoTrackRays_Chord_keyValue >= 1 and "Chord key: " .. Settings.MousetoTrackRays_Chord_KeyName))
		)
	then
		Settings.MousetoTrackRays_Chord_keyValue = 0
	end
	ui.sameLine(0,2) --makes 🔼🔽 same line
	--resets the key
	if ui.button("Reset Chord Key") then
		Settings.MousetoTrackRays_Chord_keyValue = 999
		Settings.MousetoTrackRays_Chord_KeyName = "null"
	end

	--starts listening for keys when button is pressed
	if Settings.MousetoTrackRays_Chord_keyValue == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic
			if ui.keyboardButtonDown(value) then
				if timer.running <= 0.5 then
					timer.running = timer.blength
				else
				end --anti "cooldown" bypass LOL
				Settings.MousetoTrackRays_Chord_keyValue = value
				Settings.MousetoTrackRays_Chord_KeyName = tostring(key)
			end
		end
	end
	ui.newLine(-15)

	ui.text("Position Key")
	--Toggles Button and starts the key listening
	if
		ui.button(
			Settings.MousetoTrackRays_pos_keyValue == 0 and "Press a Key."
			or (Settings.MousetoTrackRays_pos_keyValue == 999 and "Click to Set Position Key"
			or (Settings.MousetoTrackRays_pos_keyValue >= 1 and "Position key: " .. Settings.MousetoTrackRays_pos_KeyName))
		)
	then
		Settings.MousetoTrackRays_pos_keyValue = 0
	end
	ui.sameLine(0,2) --makes 🔼🔽 same line
	--resets the key
	if ui.button("Reset Position Key") then
		Settings.MousetoTrackRays_pos_keyValue = 999
		Settings.MousetoTrackRays_pos_KeyName = "null"
	end

	--starts listening for keys when button is pressed
	if Settings.MousetoTrackRays_pos_keyValue == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic
			if ui.keyboardButtonDown(value) then
				if timer.running <= 0.5 then
					timer.running = timer.blength
				else
				end --anti "cooldown" bypass LOL
				Settings.MousetoTrackRays_pos_keyValue = value
				Settings.MousetoTrackRays_pos_KeyName = tostring(key)
			end
		end
	end
	ui.newLine(-15)
	ui.text("Rotation Key")
	--Toggles Button and starts the key listening
	if
		ui.button(
			Settings.MousetoTrackRays_dir_keyValue == 0 and "Press a Key."
			or (Settings.MousetoTrackRays_dir_keyValue == 999 and "Click to Set Rotation Key"
			or (Settings.MousetoTrackRays_dir_keyValue >= 1 and "Rotation key: " .. Settings.MousetoTrackRays_dir_KeyName))
		)
	then
		Settings.MousetoTrackRays_dir_keyValue = 0
	end
	ui.sameLine(0,2) --makes 🔼🔽 same line
	--resets the key
	if ui.button("Reset Rotation Key") then
		Settings.MousetoTrackRays_dir_keyValue = 999
		Settings.MousetoTrackRays_dir_KeyName = "nil"
	end

	--starts listening for keys when button is pressed
	if Settings.MousetoTrackRays_dir_keyValue == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic
			if ui.keyboardButtonDown(value) then
				if timer.running <= 0.5 then
					timer.running = timer.blength
				else
				end --anti "cooldown" bypass LOL
				Settings.MousetoTrackRays_dir_keyValue = value
				Settings.MousetoTrackRays_dir_KeyName = tostring(key)
			end
		end
	end
	ui.newLine(-15)
	ui.text("Teleport Key")
	--Toggles Button and starts the key listening
	if
		ui.button(
			Settings.MousetoTrackRays_TP_keyValue == 0 and "Press a Key."
			or (Settings.MousetoTrackRays_TP_keyValue == 999 and "Click to Set Teleport Key"
			or (Settings.MousetoTrackRays_TP_keyValue >= 1 and "Teleport key: " .. Settings.MousetoTrackRays_TP_KeyName))
		)
	then
		Settings.MousetoTrackRays_TP_keyValue = 0
	end
	ui.sameLine(0,2) --makes 🔼🔽 same line
	--resets the key
	if ui.button("Reset Teleport Key") then
		Settings.MousetoTrackRays_TP_keyValue = 999
		Settings.MousetoTrackRays_TP_KeyName = "nil"
	end

	--starts listening for keys when button is pressed
	if Settings.MousetoTrackRays_TP_keyValue == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic
			if ui.keyboardButtonDown(value) then
				if timer.running <= 0.5 then
					timer.running = timer.blength
				else
				end --anti "cooldown" bypass LOL
				Settings.MousetoTrackRays_TP_keyValue = value
				Settings.MousetoTrackRays_TP_KeyName = tostring(key)
			end
		end
	end
end

function ToTrackWithRotation_Update()
	if Settings.MousetoTrackRays == true and timer.running <= 0 then
		if ac.isKeyDown(Settings.MousetoTrackRays_Chord_keyValue) then
			if ac.isKeyDown(Settings.MousetoTrackRays_pos_keyValue) then
				getPosfromMouse()
			end
			if ac.isKeyDown(Settings.MousetoTrackRays_dir_keyValue) then
				getDirFromMouse()
			end
		end


		if not (tp_position ~= nil and tp_position == vec3(0, 0, 0)) then
			if not (tp_direction_calc ~= nil and tp_direction_calc == vec3(0, 0, 0)) then
				tp_realDirection = lookAt(tp_position, tp_direction_calc)
			end
			ac.debug("1	: tp_position", tp_position)
			ac.debug("2	: tp_direction_calc", tp_direction_calc)
			ac.debug("3	: actual dir", tp_realDirection.look)
		end

		if
			ac.isKeyDown(Settings.MousetoTrackRays_TP_keyValue)
			and not (tp_position ~= nil and tp_position == vec3(0, 0, 0))
		then
			if (tp_direction_calc ~= nil and tp_direction_calc == vec3(0, 0, 0)) then
				physics.setCarPosition(0, tp_position, -ac.getCar(0).look)
			else
				physics.setCarPosition(0, tp_position, -tp_realDirection.look)
			end
			tp_position = vec3(0, 0, 0)
			tp_direction_calc = vec3(0, 0, 0)
			timer.running = timer.length
		end
	end
end

function ToTrackWithRotation_draw3D()
	if Settings.MousetoTrackRays == true then
		render.setDepthMode(render.DepthMode.Normal)
		if not (tp_position ~= nil and tp_position == vec3(0, 0, 0)) then
			render.debugArrow(tp_position+vec3(0,2,0), tp_position, 0.2,Driveable)
			if  not (tp_direction_calc ~= nil and tp_direction_calc == vec3(0, 0, 0)) then
				render.setDepthMode(render.DepthMode.Off)
				render.debugArrow(tp_position, tp_position + tp_realDirection.look * 3, 0.2,Driveable)
			end
		end
	end
end
--#endregion


function script.update(dt)
	--#region [Timer]
	if timer.running >= 0 then -- timer for anything to go
		timer.running = timer.running - dt
	end
	--#endregion

	--#region[Functions]
	TPtoCam_Update()
	ToTrackWithRotation_Update()
	--#endregion
end

function script.drawUI()
	if OverlayTimerKey == true then
		ui.transparentWindow("Keyandabindandacooldown", vec2(-15, -5), vec2(150, 150), false, function()
			ui.text("Key: " .. Settings.KeyName .. "\nCooldown: " .. math.round(timer.running, 1))
		end)
	end
end

function script.draw3D()
	ToTrackWithRotation_draw3D()
	TPtoCam_draw3D()
end



ui.registerOnlineExtra(	ui.Icons.Compass,
						"Manual Teleport Menu",
						nil,
						Teleportation,
						nil,
						ui.OnlineExtraFlags.Tool,
						ui.WindowFlags.NoScrollWithMouse)