local function Teleportar()
	local teleportPoint = ac.getCameraPosition()
	local TeleportAngle = ac.getCameraForward()
	physics.setCarVelocity(0, vec3(0, 0, 0))
	physics.setCarPosition(0, teleportPoint, -TeleportAngle)
end
ui.registerOnlineExtra(ui.Icons.Bluetooth, "Teleport To Camera", nil, nil, Teleportar, ui.OnlineExtraFlags.Tool)
