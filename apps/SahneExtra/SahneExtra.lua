settings = ac.storage({
	ShowLeName 				= false,
	MinecraftESP 			= false,
	MinecraftESPWalling		= false,
	MinecraftESPBoxes 		= false,
	MinecraftESPLines 		= false,
	MinecraftESPFromCam		= false,
	MinecraftESPLinesDist	= 300,
	MinecraftESPColor		= 0,
})



local ToggleLeName = false
local function DriverNamesToggle()
	local Button = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)

	--does magic that the button is only pressed once
	if Button == ToggleLeName then
		return
	end

	--do things in here
	if Button == true then
		settings.ShowLeName = not settings.ShowLeName
		if settings.ShowLeName == true then ui.toast(ui.Icons.Bug, "Names Enabled") else ui.toast(ui.Icons.Bug, "Names Disabled") end
	end

	--does magic that the button is only pressed once
	ToggleLeName = Button
end

Alpha = ac.DataLUT11.parse([[(
|5=1|
|25=1|
|50=0.5|
|100=0|)]])
Alpha.extrapolate = true

NameLutHeight = ac.DataLUT11.parse([[(
|0=-0.2|
|5=-0.2|
|12.5=0.3|
|25=1|
|35=1.5|
|50=3.6|
|60=10|
|70=30|)]])
NameLutHeight.extrapolate = true

local DistanceBetweenMeAndYou = 0
local NameSize = 15
local function DriverNames()
	local sim = ac.getSim()
	local focusedCar = ac.getCar(sim.focusedCar)
	if settings.ShowLeName == true then
		for i = 0, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			if	car.isConnected
				--[[and not car.isAIControlled]]
				and not string.find(driverName, "Traffic")
				and not string.find(driverName, ac.getDriverName(sim.focusedCar))
			then
				if sim.isFreeCameraOutside == true then
					DistanceBetweenMeAndYou = math.distance(car.position, sim.cameraPosition)
				else
					DistanceBetweenMeAndYou = math.distance(car.position, focusedCar.position)
				end
				if DistanceBetweenMeAndYou < 100 then
					local NameAlpha = Alpha:get(DistanceBetweenMeAndYou)
					local extraheight = NameLutHeight:get(DistanceBetweenMeAndYou) + car.aabbSize.x

					local screenpos = ui.projectPoint(car.position + vec3(0, extraheight, 0))

					local textsize = ui.measureDWriteText(driverName, NameSize) / 2
					ui.dwriteDrawText(driverName, NameSize, screenpos - textsize, rgbm(1, 1, 1, NameAlpha))
				end
			end
		end
	end
end

local function LeMeincraftESP()
	local sim = ac.getSim()
	local focusedCar = ac.getCar(sim.focusedCar)
	local CarColor = rgbm(settings.MinecraftESPColor, settings.MinecraftESPColor, settings.MinecraftESPColor, settings.MinecraftESPColor)
	
		for i = 1, sim.carsCount - 1 do
			local car = ac.getCar(i)
			local driverName = ac.getDriverName(i)
			local distance = math.distance(focusedCar.position, car.position)

			if distance < settings.MinecraftESPLinesDist and car.isConnected then

				if
					car.isAIControlled
					and not string.find(driverName, ac.getDriverName(sim.focusedCar))
				then
					CarColor = rgbm(1, 1, 0, 1) -- blue ai car
				end
				if
					string.find(driverName, "Traffic")
					and not string.find(driverName, ac.getDriverName(sim.focusedCar))
				then
					CarColor = rgbm(1, 0, 0, 1) -- red traffic
				end



				if settings.MinecraftESPLines == true then

					local Origin = focusedCar.position + vec3(0, focusedCar.aabbSize.y, 0)

					if settings.MinecraftESPFromCam ~= false then
						Origin = sim.cameraPosition + sim.cameraLook*2 + sim.cameraUp
					end


					local Target = car.position + vec3(0, car.aabbSize.y, 0)

					render.debugLine(Origin, Target, CarColor)
				end

				if settings.MinecraftESPBoxes == true then

					ac.debug("1 C "	..driverName	,car.aabbCenter)
					ac.debug("2 S "	..driverName	,car.aabbSize)

					local FrontBack = (car.look * (car.aabbSize.x))
					local Sides 	= (car.side * (car.aabbSize.x * 0.5))

					local Lower_Top_Left 	= (car.position) + FrontBack + Sides
					local Lower_Rear_Left 	= (car.position) - FrontBack + Sides
					local Lower_Top_Right 	= (car.position) + FrontBack - Sides
					local Lower_Rear_Right 	= (car.position) - FrontBack - Sides

					render.debugLine(Lower_Top_Left, Lower_Rear_Left, CarColor)
					render.debugLine(Lower_Top_Right, Lower_Rear_Right, CarColor)
					render.debugLine(Lower_Top_Left, Lower_Top_Right, CarColor)
					render.debugLine(Lower_Rear_Left, Lower_Rear_Right, CarColor)

					local Up = (car.up * car.aabbSize.y)
					local Upper_Top_Left 	= Lower_Top_Left   + Up
					local Upper_Rear_Left 	= Lower_Rear_Left  + Up
					local Upper_Top_Right 	= Lower_Top_Right  + Up
					local Upper_Rear_Right 	= Lower_Rear_Right + Up

					render.debugLine(Upper_Top_Left, Upper_Rear_Left, CarColor)
					render.debugLine(Upper_Top_Right, Upper_Rear_Right, CarColor)
					render.debugLine(Upper_Top_Left, Upper_Top_Right, CarColor)
					render.debugLine(Upper_Rear_Left, Upper_Rear_Right, CarColor)

					render.debugLine(Lower_Top_Left, Upper_Top_Left, CarColor)
					render.debugLine(Lower_Rear_Left, Upper_Rear_Left, CarColor)
					render.debugLine(Lower_Top_Right, Upper_Top_Right, CarColor)
					render.debugLine(Lower_Rear_Right, Upper_Rear_Right, CarColor)
				end
			end
		end
end


local function MEINKAMPFESP()
	if ui.button(settings.MinecraftESP == true and "Minecraft ESP on" or settings.MinecraftESP == false and "Minecraft ESP off") then
		settings.MinecraftESP = not settings.MinecraftESP
	end
	if settings.MinecraftESP == true then
		local Colere = ui.slider("##stegn",settings.MinecraftESPColor,0,25, 'Strength: %.0f',1)
		if Colere then
			settings.MinecraftESPColor = Colere
		end
		if ui.checkbox("Boxes",settings.MinecraftESPBoxes) then
			settings.MinecraftESPBoxes = not settings.MinecraftESPBoxes
		end
		if ui.checkbox("Lines",settings.MinecraftESPLines) then
			settings.MinecraftESPLines = not settings.MinecraftESPLines
		end
		if settings.MinecraftESPLines == true then
			ui.sameLine(0,15)
			if ui.checkbox("From Cam",settings.MinecraftESPFromCam) then
				settings.MinecraftESPFromCam = not settings.MinecraftESPFromCam
			end
		end
		
		if ui.checkbox("ExtraWalls",settings.MinecraftESPWalling) then
			settings.MinecraftESPWalling = not settings.MinecraftESPWalling
		end
		local HowFar = ui.slider("##linedis",settings.MinecraftESPLinesDist,50,2000, 'Distance: %.0f',1)
		if HowFar then
			settings.MinecraftESPLinesDist = HowFar
		end
	end
end



sim = ac.getSim()
local Replaylut = ac.DataLUT11():add(0,0):add(1,sim.replayFrameMs-0.001)
Replaylut.extrapolate = true

local function replaything()
	if ac.isInReplayMode() then
		local sim = ac.getSim()
		local HowManyFrames 		= sim.replayFrames
		local CurrentFrameLocation 	= sim.replayCurrentFrame
		ac.debug("2",sim.replayFrameMs)
		ui.setNextItemWidth(ui.windowWidth()-30)
		local MainFramesSlider, MainFramesOn = ui.slider("##MainFrame", CurrentFrameLocation, 0, HowManyFrames, "Current Frame: %.5f", 1)

		local integer, dec = string.match(tostring(MainFramesSlider), "([^.]+)%.(.+)")
		
		dec 	= tostring(dec)
		dec 	= "0." .. dec
		dec 	= tonumber(dec)
		dec 	= Replaylut:get(dec)

		if MainFramesOn then
			ac.setReplayPosition(MainFramesSlider,dec)
		end

	end
end

function script.SahneExtra()
	ui.tabBar("##Bracked",function ()
		ui.tabItem("ESP",MEINKAMPFESP)
		ui.tabItem("Replay?",replaything)
	end)
end

function script.fullscreenUI()
	DriverNamesToggle()
	DriverNames()
end

function script.draw3D()
	render.setBlendMode(render.BlendMode.Opaque)
	render.setCullMode(render.CullMode.ShadowsDouble)
	if settings.MinecraftESPWalling == true then
		render.setDepthMode(render.DepthMode.Off)
	else
		render.setDepthMode(render.DepthMode.Normal)
	end
	
	if settings.MinecraftESP == true then
		LeMeincraftESP()
	end
end




ac.setLogSilent(true)
local function yeet()
	if io.dirExists(ac.getFolder(ac.FolderID.Cfg) .. "\\ExtraTroll\\") ~= true then
		io.createDir(ac.getFolder(ac.FolderID.Cfg) .. "\\ExtraTroll\\")
	end

	local sim = ac.getSim()
	if sim.isOnlineRace == true then
		print("we online")
		local Name = ac.getServerName()
		local LeIp = ac.getServerIP()
		local LePort = ac.getServerPortTCP()
		local Server = tostring(Name.."_"..LeIp.."_"..LePort)
		ServerCfg = ac.INIConfig.onlineExtras()
		ac.debug("ServerCfg",ServerCfg)
		if ServerCfg ~= nil then
			print("saving server ceefg")
			io.save(ac.getFolder(ac.FolderID.Cfg) .. "\\ExtraTroll\\" .. Server .. ".ini" ,ServerCfg)
		end
		print("end")
	end
end

yeet()
