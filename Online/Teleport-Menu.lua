local timer = 0
CameraKey = ac.storage({
	v = -1, --key value for ac
	n = "", --key name for user
	x = 0, --x pos for overlay pos
	y = 0 --x pos for overlay pos
})



--Menu
local function Teleportation💀()
	--showing timer seems logical to me here
	ui.text("Cooldown: " .. math.round(timer,1))

	ui.tabBar("Atabbar", function()--A TAB BAR
		ui.tabItem("Car to Camera", keybindtp)--ayo
		ui.tabItem("Car to Car", cartocar)--piss
	end)
end

function keybindtp() --first tab
	ui.text("Teleport to Camera")
	--Toggles Button and starts the key listening
	if ui.button(CameraKey.v == 0 and "Press a Key." or (CameraKey.v == -1 and "Click to Set Key" or (CameraKey.v >= 1 and "Selected key: " .. CameraKey.n))) then CameraKey.v = 0 end 
	ui.sameLine() --makes 🔼🔽 same line
	--resets the key
	if ui.button("Reset Key") then CameraKey.v = -1 CameraKey.n = "null" end
	--shows cooldown timer via script.drawUI
	if ui.checkbox("Show Cooldown and Key", OverlayTimerKey) then
		OverlayTimerKey = not OverlayTimerKey
	end	

	--add droptown for where or x y of monitor + maybe size?



	--maybe add a map here or create a new tab for it, easy camera movement will prolly take code from comfig 👲🏿



	--starts listening for keys when button is pressed
	if CameraKey.v == 0 then
		for key, value in pairs(ui.KeyIndex) do -- figure out how to add other input support, maybe need manual select cuz previous try was catostropgic 
			if ui.keyboardButtonDown(value) then
				if timer <= 0.5 then timer = 0.5 else end --anti "cooldown" bypass LOL 
				CameraKey.v = value
				CameraKey.n = tostring(key)
			end
		end
	end
end


function cartocar()--just straight up ripped from teleport to car cause it seems modular af LOL
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
		ui.transparentWindow("Keyandabindandacooldown",vec2(-15,-5),vec2(150,150),false,function ()
			ui.text("Key: " .. CameraKey.n ..  "\nCooldown: ".. math.round(timer,1))
		end) 
	end
end


ui.registerOnlineExtra(ui.Icons.Compass, "Manual Teleport Menu", nil, Teleportation💀, nil, ui.OnlineExtraFlags.Tool)
