local timer = 0
TPkey = ac.storage({v = -1,n = ""})

function script.update(dt)
	if timer >= 0 then
		timer = timer - dt
	end

	if OutOfApp == true then
		TPLeKey()
	end

	function TP()
		local teleportPoint = ac.getCameraPosition()
		local TeleportAngle = ac.getCameraForward()
		physics.setCarPosition(0, teleportPoint, -TeleportAngle)
		physics.setCarVelocity(0, vec3(0, 0, 0))
	end
end

function script.drawUI()
	if OutOfApp == true then
	ui.transparentWindow("21thirdteen",vec2(-15,-5),vec2(150,150),false,function ()
		ui.text("Key: " .. TPkey.n ..  "\nCooldown: ".. math.round(timer,1))
	end) end
end

local function TPStuff()
	ui.text("Teleport to Camera")
	if ui.button(TPkey.v == 0 and "Press a Key." or (TPkey.v == -1 and "Click to Set Key" or (TPkey.v >= 1 and "Selected key: " .. TPkey.n))) then TPkey.v = 0 end ui.sameLine()
	if ui.button("Reset Key") then TPkey.v = -1 TPkey.n = "null" end

	if ui.checkbox("Enable Keybind Outside of App", OutOfApp) then
		OutOfApp = not OutOfApp
	end	if ui.itemHovered() then ui.tooltip(function () ui.text("will show cooldown in the top left corner")end) end

	ui.text("Cooldown: " .. math.round(timer,1))
	if TPkey.v == 0 then
		for key, value in pairs(ui.KeyIndex) do
			if ui.keyboardButtonDown(value) then
				timer = 0.5
				TPkey.v = value
				TPkey.n = tostring(key)
			end
		end
	end
end

function TPLeKey()
	if ui.keyboardButtonPressed(TPkey.v) and timer <= 0 then
		TP()
		timer = 3
	end
end

local function TPHud()
	TPStuff()
	TPLeKey()
end

ui.registerOnlineExtra(ui.Icons.Compass, "TP to Camera", nil, TPHud, nil, ui.OnlineExtraFlags.Tool)
