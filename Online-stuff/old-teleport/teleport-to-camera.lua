local function Teleportar()
	local teleportPoint = ac.getCameraPosition()
	local TeleportAngle = ac.getCameraForward()
	physics.setCarPosition(0, teleportPoint, -TeleportAngle)
    physics.setCarVelocity(0, vec3(0, 0, 0))
end
ui.registerOnlineExtra(ui.Icons.Bluetooth, "TP to Cam", nil, nil, Teleportar, ui.OnlineExtraFlags.Tool)
