
local Replaylut = ac.DataLUT11():add(0,0):add(1,ac.getSim().replayFrameMs-0.001)
Replaylut.extrapolate = true

local sim = ac.getSim()
local inbetweens = 0
local Beginning = nil
local Ending = nil
local lookatme = false
local LookingCamera = nil


function replaything()
	if ac.isInReplayMode() then
		local HowManyFrames 		= sim.replayFrames
		local CurrentFrameLocation 	= sim.replayCurrentFrame
		if Beginning == nil or Ending == nil then

			Ending = HowManyFrames
		end

		ui.setNextItemWidth(ui.windowWidth()-30)
		local StartCut, StartCutOn = ui.slider("##StartCut", Beginning, 0, HowManyFrames, "Start Frame: %.3f", 1)

		ui.setNextItemWidth(ui.windowWidth()-30)
		local EndCut, EndCutOn = ui.slider("##EndCut", Ending, Beginning, HowManyFrames, "End Frame: %.3f", 1)

		if EndCutOn or StartCutOn then
			Beginning = StartCut
			Ending = EndCut
		end

		ui.setNextItemWidth(ui.windowWidth()-30)
		local MainFramesSlider, MainFramesOn = ui.slider("##MainFrame", CurrentFrameLocation, Beginning, Ending, "Current Frame: %.10f", 1)
		local integer, dec = string.match(tostring(MainFramesSlider), "([^.]+)%.(.+)")
		
		dec 	= tostring(dec)
		dec 	= "0." .. dec
		dec 	= tonumber(dec)
		dec 	= Replaylut:get(dec)

		if MainFramesOn then
			ac.setReplayPosition(MainFramesSlider,dec)
			inbetweens = dec
		end
		ui.text("HowManyFrames: "..HowManyFrames)
		ui.text("CurrentFrameLocation(Frame|TransitionMS): "..CurrentFrameLocation .." | " .. inbetweens)
	end

	if ui.checkbox("Shitty Look at me", lookatme) then
		lookatme = not lookatme
		if lookatme and not LookingCamera then
			local holdError
			LookingCamera, holdError = ac.grabCamera("Look at me bruh")
			if not LookingCamera then
				ui.toast(ui.Icons.Warning, string.format("Couldn’t grab camera: %s", holdError))
				lookatme = false
			else
				LookingCamera.ownShare = 0
			end
		end
	end
end

local function lookAt(origin,target)
	local zaxis = vec3():add(target - origin):normalize()
	local xaxis = zaxis:clone():cross(vec3(0, 1, 0)):normalize()
	local yaxis = xaxis:clone():cross(zaxis):normalize()
	local viewMatrix = mat4x4(
	vec4(xaxis.x, xaxis.y, xaxis.z, -xaxis:dot(origin)),
	vec4(yaxis.x, yaxis.y, yaxis.z, -yaxis:dot(origin)),
	vec4(zaxis.x, zaxis.y, zaxis.z, -zaxis:dot(origin)),
	vec4(0, 1, 0, 1))
	return viewMatrix
end

local fov = 50
function LookingAtShit()
	if LookingCamera == nil then
		return
	end
	LookingCamera.ownShare = math.applyLag(LookingCamera.ownShare, lookatme and 1 or 0, 0.9, ac.getSim().dt * 5)
	ac.debug("share",LookingCamera.ownShare)
	if not lookatme and LookingCamera.ownShare < 0.01 then
		LookingCamera:dispose()
		LookingCamera = nil
	else
		local c = ac.getCar(0)
		local cam = sim.cameraPosition:clone()
		local LookAtMatrix = lookAt(cam,c.position * vec3(1,0.5,1))

		if ui.keyboardButtonDown(ui.KeyIndex.Left) then
			cam:add(-sim.cameraSide / 2)
		end
		if ui.keyboardButtonDown(ui.KeyIndex.Right) then
			cam:add(sim.cameraSide / 2)
		end
		if ui.keyboardButtonDown(ui.KeyIndex.Up) then
			cam:add(sim.cameraLook / 2)
		end
		if ui.keyboardButtonDown(ui.KeyIndex.Down) then
			cam:add(-sim.cameraLook / 2)
		end
		if ui.keyboardButtonDown(ui.KeyIndex.RightShift) then
			cam:add(sim.cameraUp / 2)
		end
		if ui.keyboardButtonDown(ui.KeyIndex.RightControl) then
			cam:add(-sim.cameraUp / 2)
		end
		if ui.keyboardButtonDown(ui.KeyIndex.Insert) then
			fov = fov - 1
		end
		if ui.keyboardButtonDown(ui.KeyIndex.Delete) then
			fov = fov + 1
		end

		LookingCamera.transform.position = cam
		LookingCamera.transform.look = LookAtMatrix.look
		LookingCamera.transform.up = vec3(0,1,0)
		LookingCamera.fov = fov
		-- LookingCamera.dofFactor = 1
		-- LookingCamera.dofDistance = 4
		LookingCamera:normalize()
	end
end