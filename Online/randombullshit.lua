---@diagnostic disable: param-type-mismatch
local mem = ac.storage({
	pos = vec3(0, 0, 0),
	dir = vec3(0, 0, 0),
	vel = vec3(0, 0, 0),
	gear = 0,
	rpm = 0,
	extraspeeder = 1,
	extraspeedermouse = 1,
	aicheckbox = false,
	aiLevel = 0.5,
	aiAgression = 0.5,
	keybindtext = " ",
})

local function savepos1()
	mem.pos = ac.getCar(0).position
	mem.dir = ac.getCar(0).look
	mem.vel = ac.getCar(0).velocity
	mem.gear = ac.getCar(0).gear
	mem.rpm = ac.getCar(0).rpm
end

local function loadpos1()
	physics.setCarPosition(0, mem.pos, -mem.dir)
	physics.setCarVelocity(0, mem.vel:mul(vec3(mem.extraspeeder, mem.extraspeeder * 0.8, mem.extraspeeder)))
	physics.setEngineRPM(0, mem.rpm)
	if mem.extraspeeder <= 1 then
		physics.engageGear(0, mem.gear)
	else
		if mem.extraspeeder > 1 then
			physics.engageGear(0, ac.getCar(0).gearCount)
		end
	end
end

local function TeleportCam()
	local tp = ac.getCameraPosition()
	local dir = ac.getCameraForward()
	physics.setCarPosition(0, tp + dir * 5, -dir)
	physics.setCarVelocity(0, dir:mul(vec3(mem.extraspeedermouse, mem.extraspeedermouse, mem.extraspeedermouse)))
end

local function tab2()
	if ui.button("SavePos") then
		savepos1()
		mem.keybindtext = "Saved"
	end
	ui.sameLine()
	if ui.button("LoadPos") then
		loadpos1()
		mem.keybindtext = "Loaded"
	end

	local extraspeed = ui.slider("##" .. "Speed", mem.extraspeeder, 0, 10, "Speed Multiplyer" .. ": %.1f")
	if extraspeed then
		mem.extraspeeder = extraspeed
	end
	if ui.checkbox("keybinds", keybinder) then
		keybinder = not keybinder
	end

	if keybinder == true then
		ui.sameLine()
		ui.text("left arrow save pos\nright arrow load pos")
	end
	if keybinder == true and ui.keyPressed(ui.Key.Left) then
		savepos1()
		mem.keybindtext = "Saved"
	end
	if keybinder == true and ui.keyPressed(ui.Key.Right) then
		loadpos1()
		mem.keybindtext = "Loaded"
	end

	if ui.checkbox("TP to Cam", keybindermouse) then
		keybindermouse = not keybindermouse
	end
	if keybindermouse == true and ui.keyPressed(ui.Key.Home) then
		TeleportCam()
		mem.keybindtext = "TP to Cam"
	end
	if keybindermouse == true then
		local extraspeedmouse = ui.slider("##" .. "unique",mem.extraspeedermouse,0,1000,"Speed: %.0fm/s: " .. mem.extraspeedermouse * 3.6 .. "Kmh",2)
		if extraspeedmouse then
			mem.extraspeedermouse = extraspeedmouse
		end
	end
	ui.text("last interaction: " .. mem.keybindtext)
end
local function tab1()
	ui.text("Ai only uses fastlane.ai")
	if ui.checkbox("Enable AI/Autopilot", mem.aicheckbox) then
		mem.aicheckbox = not mem.aicheckbox
		if mem.aicheckbox == true then
			physics.setCarAutopilot(true)
		else
			physics.setCarAutopilot(false)
		end
	end
	if mem.aicheckbox == true then
		ui.text("ai will break after teleporting\nrecheck it to fix it")
	end
	if mem.aicheckbox == true then
		local aiLevel = ui.slider("##" .. "AI Level", mem.aiLevel, 0.43, 1, "AI Level" .. ": %.2f")
		if aiLevel then
			mem.aiLevel = aiLevel
			physics.setAILevel(0, mem.aiLevel)
		end
		local aiAgression = ui.slider("##" .. "AI Agression", mem.aiAgression, 0, 1, "AI Agression" .. ": %.2f")
		if aiAgression then
			mem.aiAgression = aiAgression
			physics.setAIAggression(0, mem.aiAgression)
		end
	end
end

local function tab25()
	if ui.checkbox("kebab", nwind) then
		nwind = nwind
		ac.setMessage("Obama has overtaken", "the middle east")
	end
end


local function ObamiumHUD()

	ui.tabBar("sabcar", function()
		ui.tabItem("AI", tab1)
		ui.tabItem("TP", tab2)
		ui.tabItem("Testing", tab25)
	end)

end
ui.registerOnlineExtra(ui.Icons.Crosshair, "ExtraStuff", nil, ObamiumHUD, nil, ui.OnlineExtraFlags.Tool)
