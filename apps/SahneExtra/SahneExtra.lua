settings = ac.storage({
	ShowLeName 		= false,

	ESP 			= false,
	ESPMaxDist		= 300,

	ESP2D 			= false,
	ESP2DBoxes 		= false,
	ESP2DLines 		= false,

	ESP3D 			= false,
	ESP3DBoxes 		= false,
	ESP3DLines 		= false,
	ESP3DWallBetter	= false,
	ESP3DFromCam	= false,
})
require("extras\\ESP_and_drivernames")
require("extras\\replay")
require("extras\\extrabuttons")
local sim = ac.getSim()

local function tp()
	if ui.button("reset") then
		ac.resetCar()
	end
	ui.sameLine(0,2)
	if ui.button("step back") then
		ac.takeAStepBack()
	end
end

function script.SahneExtra()
	ui.tabBar("##Bracked",function ()
		ui.tabItem("TPs",tp)
		ui.tabItem("ESP",ESPSettings)
		ui.tabItem("Replay?",replaything)
		ui.tabItem("Extra Car buttons",extrabuttons)
	end)
end

function script.update(dt)
	DriverNames_Toggle()
	LookingAtShit()
end

function script.fullscreenUI()
	if settings.ESP2D and settings.ESP then
		ESP2D()
	end
	if settings.ShowLeName then
		DriverNames_Draw()
	end
	
end

-- rn only esp 3d
function script.draw3D()
	render.setBlendMode(render.BlendMode.Opaque)
	render.setCullMode(render.CullMode.ShadowsDouble)
	if settings.ESP3DWallBetter == true then
		render.setDepthMode(render.DepthMode.Off)
	else
		render.setDepthMode(render.DepthMode.Normal)
	end
	if settings.ESP3D and settings.ESP then
		ESP3D()
	end
end


ac.setLogSilent(true)
local function yeet()
	if io.dirExists(ac.getFolder(ac.FolderID.Cfg) .. "\\ExtraTroll\\") ~= true then
		io.createDir(ac.getFolder(ac.FolderID.Cfg) .. "\\ExtraTroll\\")
	end
	if sim.isOnlineRace == true then
		print("we online")
		local Name = ac.getServerName()
		local LeIp = ac.getServerIP()
		local LePort = ac.getServerPortTCP()
		local Server = tostring(LeIp .. "_" .. LePort)
		ServerCfg = ac.INIConfig.onlineExtras()
		ac.debug("ServerCfg",ServerCfg)
		if ServerCfg ~= nil then
			if io.fileExists(ac.getFolder(ac.FolderID.Cfg) .. "\\ExtraTroll\\" .. Server .. ".ini") ~= true then
				io.save(ac.getFolder(ac.FolderID.Cfg) .. "\\ExtraTroll\\" .. Server .. ".ini", ServerCfg)
				print("saving server ceefg")
			end
		end
		print("end")
	end
end
yeet()