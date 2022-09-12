---@diagnostic disable: lowercase-global, param-type-mismatch
ui.setAsynchronousImagesLoading(true)

function script.Draw3D(dt)
	ac.debug("AI controlled", ac.getCar(0).isAIControlled)
end

--	ac.onChatMessage(function(message, carIndex, sessionID)
--		ac.log(
--			string.format(
--				"Message `%s` from %s, sessionID=%s, filtering: %s",
--				message,
--				carIndex,
--				sessionID,
--				message:match("ass") ~= nil
--			)
--		)
--		if message:match("damn") ~= nil and carIndex ~= 0 then
--			-- no swearing on my christian server
--			return true
--		end
--	end)

local function tab1()
	ui.text("is *physics.* usage allowed\n via app? The answer is: " .. tostring(physics.allowed()))
end

local function tab2()
	local allah = ac.storage({
		pos = vec3(),
		pos1 = 0,
		pos2 = 0,
		pos3 = 0,
		pitch = 0,
		yaw = 0,
	})

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

local function tab3()
	if ui.button("reset") then
		ac.resetCar()
	end
	if ui.button("step back") then
		ac.takeAStepBack()
	end

	ui.text("\nteleports lua has access to (maybe void)")
	for i, j in pairs(ac.SpawnSet) do
		if ui.button(i) then
			physics.teleportCarTo(0, j)
		end
		ui.sameLine()
	end
end

local function tab4()
	ui.text("1. Gas:      " .. tostring(math.floor(100 * ac.getCar(0).gas)))
	ui.text("1. Breaks:   " .. tostring(math.floor(100 * ac.getCar(0).brake)))
	ui.text("\n")
	ui.text("2. Extra E:  " .. tostring(ac.getCar(0).extraE))
	ui.text("2. Extra F:  " .. tostring(ac.getCar(0).extraF))
	ui.newLine(25)
end

function script.windowMain()

	--best slider example without fucking ac.storage
	local getfov = ac.getCameraFOV()
	funnie = getfov
	local funnie, changed = ui.slider("##2cammy", funnie, 0.001, 50, "Fov: %.04f", 4)
	if changed then
		fovthing = funnie
		ac.setCameraFOV(fovthing)
	end

	ui.text("Speed: " .. tostring(math.floor(ac.getCar(0).speedKmh).." km/h"))
	ui.newLine(10)
	if ui.checkbox("Tabs", bruh) then
		bruh = not bruh
	end
	if bruh then
		ui.tabBar("someTabBarID", function()
			ui.tabItem("Checks", tab1)
			ui.tabItem("Cammy", tab2)
			ui.tabItem("Phy", tab3)
			ui.tabItem("rdm", tab4)
		end)
	end
end
