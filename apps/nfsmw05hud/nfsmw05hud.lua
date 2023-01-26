-- preload
ui.setAsynchronousImagesLoading(true)
require("preload")
local firstrun = true
local rpmstyle = ""
local needle = ""

local dseg7 = ui.DWriteFont("DSEG7 Classic","\\fonts")
local catfont = ui.DWriteFont("Conduit ITC","\\fonts")
local eurostile = ui.DWriteFont("Eurostile Bold","\\fonts")
-- preload



local hud = ac.storage({
	style = 0,
	overwrite = false,
	realpos = false,
	Needle_OR = 0,
	Tacho_OR = 0,
	RPM_OR = 0,
	num_OR = false,
	cat = false,
	extras = false,
	needlecolor = rgb(0.985,0.75,0.45),
	tachocolor = rgb(0.985,0.75,0.45),
	rpmcolor = rgb(1,1,1),
	mirror = false,
	mirrorReplace = false,
})


-- color stuff
local stored = ac.storage({
	color = rgb(0, 0.2, 1),
})

local editing = false
local edittype = {
	tacho = false,
	rpm = false,
	needle = false,
}
local colorFlags = bit.bor(
	ui.ColorPickerFlags.NoAlpha,
	ui.ColorPickerFlags.NoSidePreview,
	ui.ColorPickerFlags.PickerHueWheel
)
local function ColorBlock(key)
	ui.windowSize()
	key = key or "color"
	local col = stored[key]:clone()
	-- added
	if edittype.tacho == true then
		stored.color = hud.tachocolor
	elseif edittype.rpm == true then
		stored.color = hud.rpmcolor
	elseif edittype.needle == true then
		stored.color = hud.needlecolor
	end
	-- added end
	ui.colorPicker("##color", col, colorFlags)
	if ui.itemEdited() then
		stored[key] = col
		editing = true
	elseif editing and not ui.itemActive() then
		editing = false
	end
	-- added2
	if edittype.tacho == true then
		hud.tachocolor = stored.color
	elseif edittype.rpm == true then
		hud.rpmcolor = stored.color
	elseif edittype.needle == true then
		hud.needlecolor = stored.color
	end
	-- added end
end
-- color end

-- settings stuff

local find = refbool(false)
-- settings stuff
-- settings menu
function script.TachoSettings()
	ui.tabBar("##TABBAR", bit.bor(ui.TabBarFlags.IntegratedTabs,ui.TabBarFlags.NoTooltip), function ()
		ui.tabItem("Tacho",TachSettings)
		ui.tabItem("Tacho Extras",TachoOverwrites)
		ui.tabItem("Mirror",MirrorSettings)
	end)
end

function script.onHideTachoSettings()
	find.value = false
end

function TachSettings()
	-- Style Select
	ui.setNextItemWidth(100)
	ui.combo("##HUDSTYLE", "HUD: " .. hud.style, function()
		for i = 0, 10, 1 do
			if ui.selectable("Style: " .. i) then
				hud.style = i
			end
		end
	end) ui.sameLine()

	if ui.button("Reset Color",ui.ButtonFlags.PressedOnDoubleClick) then
		hud.needlecolor = rgb(0.985,0.75,0.45)
		hud.tachocolor = rgb(0.985,0.75,0.45)
		hud.rpmcolor = rgb(1,1,1)
	end
	ui.sameLine()
	if ui.checkbox("Real Pos",hud.realpos) then
		hud.realpos = not hud.realpos
	end

	if hud.realpos == true then
		ui.sameLine()
		ui.checkbox("Find",find)
	end


	if ui.button("Background Color") then
		ColorBlock(nil,tacho)
		if edittype.tacho ~= true then
			edittype.tacho = true
			edittype.rpm = false
			edittype.needle = false
		else 
			edittype.tacho = false
		end
	end ui.sameLine()

	if ui.button("RPM/Turbo Color") then
		ColorBlock(nil,tacho)
		if edittype.rpm ~= true then
			edittype.tacho = false
			edittype.rpm = true
			edittype.needle = false
		else 
			edittype.rpm = false
		end
	end ui.sameLine()

	if ui.button("Needle Color") then
		ColorBlock(nil,tacho)
		if edittype.needle ~= true then
			edittype.tacho = false
			edittype.rpm = false
			edittype.needle = true
		else 
			edittype.needle = false
		end
	end
	ui.newLine(1)
	if edittype.tacho == true or edittype.rpm == true or edittype.needle == true then
		ui.childWindow("##coloredit2",vec2(335,400),false,ui.WindowFlags.NoScrollbar, function ()
			ui.text(edittype.tacho == true and "Editing Tacho" or edittype.rpm == true and "Editing RPM Style" or edittype.needle == true and "Editing Needle" )
			ui.setNextItemWidth(320)
			ColorBlock()
		end)
	end
end
-- settings menu


-- overwrite menu
function TachoOverwrites()
	if ui.checkbox("Bars",hud.extras) then
		hud.extras = not hud.extras
	end 
	ui.sameLine()
	if ui.checkbox("Num Brightness",hud.num_OR) then
		hud.num_OR = not hud.num_OR
	end 
	ui.sameLine()
	if ui.checkbox("Cat",hud.cat) then
		hud.cat = not hud.cat
	end 
	ui.sameLine()
	if ui.checkbox("Overwrites",hud.overwrite) then
		hud.overwrite = not hud.overwrite
	end


	if hud.overwrite == true then
		ui.setNextItemWidth(100)
		ui.combo("##Tacho_OR", "BG: " .. hud.Tacho_OR, function()
			for i = 0, 10, 1 do
				if ui.selectable("BG: " .. i) then
					hud.Tacho_OR = i
				end
			end
		end)
		ui.sameLine() ui.setNextItemWidth(100)
		ui.combo("##Needle_OR", "Needle: " .. hud.Needle_OR, function()
				if ui.selectable("Needle: 0") then
					hud.Needle_OR = 0
				end
				if ui.selectable("Needle: 1") then
					hud.Needle_OR = 1
				end
				if ui.selectable("Needle: 7") then
					hud.Needle_OR = 7
				end
		end)
		ui.sameLine() ui.setNextItemWidth(100)
		ui.combo("##RPM_OR", "RPM: " .. hud.RPM_OR, function()
			for i = 0, 10, 1 do
				if ui.selectable("RPM: " .. i) then
					hud.RPM_OR = i
				end
			end
		end)

	end
end
-- overwrite menu

-- Needle Rotation and smoothing
--ui.SmoothInterpolation is a table in disguise, dont use inside "script."
local rpmSmooth = ui.SmoothInterpolation(ac.getCar(0).rpm, 5)
local RotationLut = ac.DataLUT11()
RotationLut.extrapolate = true
RotationLut:add(-1, 0)
-- Needle Rotation
local tenkClamp = false


-- Turbo Needle Rotation and smoothing
local turboSmooth = ui.SmoothInterpolation(ac.getCar(0).turboBoost, 5)
local TurboLut = ac.DataLUT11()
TurboLut.extrapolate = true
TurboLut:add(-2,-54)
TurboLut:add(0,0)
TurboLut:add(2, 54) 
-- Turbo Needle Rotation and smoothing

-- easy edit things
local start = vec2(0, 0)
local speedpos = vec2(148, 307)
local gearpos = vec2(257,145)
local num_color = rgbm(0,0,0,1)
local num_color_BG = rgbm(0,0,0,0.25)
-- easy edit things

-- resizing lut for number / gear / shift up triangle
local resizething = ac.DataLUT11()
resizething:add(0,0)
resizething:add(512,1)
resizething.extrapolate = true
-- resizing lut for number / gear / shift up triangle

--##################################################################################cat

local catrpmlut = ac.DataLUT11()
catrpmlut.extrapolate = true
catrpmlut:add(0,0)
catrpmlut:add(10500, 235)

local catturbolut = ac.DataLUT11()
catturbolut.extrapolate = true
catturbolut:add(0,0)
catturbolut:add(2,210.4)

local catspeed = vec2(310,240)
local catgear = vec2(400,175)

--##################################################################################cat


local AutosizeY = ac.DataLUT11():add(1080,312):add(2160,624)
local AutosizeX = ac.DataLUT11():add(1920,312):add(3840,624)
AutosizeY.extrapolate = true
AutosizeX.extrapolate = true
local WinzY = ac.getSim().windowHeight
local WinzX = ac.getSim().windowWidth

--start of main thing 
function script.Tacho()
	local TachoPos = ui.windowPos()

	--keep aspect ratio same
	local TachoX, TachoY = ui.windowWidth(), ui.windowHeight()

	
	if hud.realpos == true then
		if find.value == true then
			ui.toolWindow("bruhilostit",TachoPos,vec2(TachoX,TachoY),function () 
			ui.drawRectFilled(start,vec2(TachoX,TachoY), rgbm(1,1,1,0.2),0, ui.CornerFlags.All) end)
		end
		TachoX = AutosizeX:get(WinzX)
		TachoY = AutosizeY:get(WinzY) 
		TachoPos = vec2(WinzX * 0.818 , WinzY * 0.649)
		if find.value == true then
		ui.toolWindow("bruhilostit",TachoPos,vec2(TachoX,TachoY),function () 
			ui.drawRectFilled(start,vec2(TachoX,TachoY), rgbm(1,1,1,0.2),0, ui.CornerFlags.All) end)
		end
	end


	local ratio = TachoX / TachoY
	if ratio < 1 then
		TachoY = TachoX
	else
		TachoX = TachoY
	end
	local Tachosize = vec2(TachoX, TachoY)
	--keep aspect ratio same


	--number color auto adjust
	if hud.tachocolor < rgb(0.3,0.3,0.3) then
			num_color = rgbm(1,1,1,1)
			num_color_BG = rgbm(1,1,1,0.25)
		else
			num_color = rgbm(0,0,0,1)
			num_color_BG = rgbm(0,0,0,0.25)
			
	end
	if hud.num_OR == true then
		if num_color == rgbm(1,1,1,1) and num_color_BG == rgbm(1,1,1,0.25) then
			num_color = rgbm(0,0,0,1)
			num_color_BG = rgbm(0,0,0,0.25)
		else
			num_color = rgbm(1,1,1,1)
			num_color_BG = rgbm(1,1,1,0.25)
		end
	end
	--number color auto adjust

	-- resizing for alot of things, prolly a bad idea
	local resized = resizething:get(TachoX)
	-- resizing for alot of things, prolly a bad idea

	-- car stuff
	local car = ac.getCar(0)
	local rpm = car.rpm
	local maxrpm = car.rpmLimiter
	local rpmlight = maxrpm * 0.925
	local rpmsmoothed = rpmSmooth(rpm)
	
	local 	bar = car.turboBoost
			bar = bar
			bar = math.clamp(bar, -2, 2)
			bar = TurboLut:get(turboSmooth(bar))

	local gear = car.gear
	local speed = car.speedKmh
	speed = math.floor(speed)
	-- car stuff

	if hud.cat ~= true then
		ui.transparentWindow("##Tachometer", TachoPos,Tachosize,function ()

			if firstrun == true then
				if maxrpm > 9000 then
					RotationLut:add(10000, 230)
				elseif maxrpm > 8000 then
					RotationLut:add(9000, 230)
				elseif maxrpm > 7000 then
					RotationLut:add(8000, 230)
				elseif maxrpm > 1 then
					RotationLut:add(7000, 230)
				end
				firstrun = false
			end

			if hud.overwrite == true then
				for i = 0, 10, 1 do
					if hud.Tacho_OR == i then
						tach = style[i].tach
					end
					if hud.Needle_OR == i then
						needle = style[i].needle
					end
					if hud.RPM_OR == i then
						if maxrpm > 9000 then
							rpmsmoothed = math.clamp(rpmsmoothed, 0, 10005)
							rpmstyle = style[i].rpm10k
						elseif maxrpm > 8000 then
							rpmstyle = style[i].rpm9k
						elseif maxrpm > 7000 then
							rpmstyle = style[i].rpm8k
						elseif maxrpm > 1 then
							rpmstyle = style[i].rpm7k
						end
					end
				end
			else
				for i = 0, 10, 1 do
					if hud.style == i then
						tach = style[i].tach
						needle = style[i].needle
						if maxrpm > 9000 then
							rpmstyle = style[i].rpm10k
							rpmsmoothed = math.clamp(rpmsmoothed, 0, 10005)
						elseif maxrpm > 8000 then
							rpmstyle = style[i].rpm9k
						elseif maxrpm > 7000 then
							rpmstyle = style[i].rpm8k
						elseif maxrpm > 1 then
							rpmstyle = style[i].rpm7k
						end
					end
				end
			end
			--whole tach
			ui.drawImage(tach, start, Tachosize, hud.tachocolor, nil, nil, false)
			ui.beginRotation()
			ui.drawImage(redline, vec2(TachoX/14,TachoY/20), Tachosize - vec2(TachoX/18,TachoY/20), rgbm(0.66,0,0,0.8), nil, nil, true)
			ui.endRotation()
			ui.drawImage(rpmstyle,vec2(TachoX/40,TachoY/40), Tachosize - vec2(TachoX/40,TachoY/25), hud.rpmcolor, nil, nil, false)
			--whole tach

			--set font for dwrite
			ui.pushDWriteFont(dseg7)
			--gears
			if gear < 0 then
				ui.dwriteDrawText("R", 48 * resized, gearpos * resized, num_color)--have R when reverse
			elseif gear == 0 then
				ui.dwriteDrawText("N", 48 * resized, gearpos * resized, num_color)
			else
				ui.dwriteDrawText(gear, 48 * resized, gearpos * resized, num_color)--show numbers when not in reverse
			end								
			ui.dwriteDrawText("8", 48 * resized, gearpos * resized, num_color_BG)--shadow like for the numbers
			--gears

			--shift up triangle
			if rpm > rpmlight then
				ui.setCursor(vec2(212,156) * resized)
				ui.image(shiftup, vec2(46,46) * resized, num_color, true)
			else
				ui.setCursor(vec2(212,156) * resized)
				ui.image(shiftup, vec2(46,46) * resized, num_color_BG, true)
			end
			--shift up triangle

			--speed
			ui.setCursor(speedpos * resized)
			ui.dwriteTextAligned(speed, 75 * resized, ui.Alignment.End, ui.Alignment.Start, vec2(200, 100) * resized, false, num_color)
			ui.setCursor(speedpos * resized)
			ui.dwriteTextAligned("888", 75 * resized, ui.Alignment.End, ui.Alignment.Start, vec2(200, 100) * resized, false, num_color_BG)
			ui.popDWriteFont() --remove font
			--speed

			--needle
			ui.beginRotation()
			ui.drawImage(needle, start, Tachosize, hud.needlecolor, nil, nil, true)
			ui.endRotation(-RotationLut:get(rpmsmoothed)+25)
			--turbo
			if car.turboCount > 0 then
				ui.drawImage(turbo, start + vec2(TachoX/32,TachoY/64), Tachosize - vec2(TachoX/32,-TachoY/128), hud.rpmcolor, nil, nil, false)
				ui.beginRotation()
				ui.drawImage(turboneedle, start + vec2(TachoX/32,TachoY/32), Tachosize - vec2(TachoX/32,TachoY/32), hud.needlecolor, nil, nil, true)
				ui.endRotation(bar+90)
			end
		end)
		if hud.extras == true then
			ui.transparentWindow("##nitroslomo", TachoPos - Tachosize/8,Tachosize+(Tachosize/4),function () 
				local winz = ui.windowSize()
				local winz_m = vec2(winz.x/16,winz.y/16)

				--slo mo ico and bar
				ui.beginRotation()
				ui.drawImage(meter,start + winz_m,winz - winz_m, rgb.from0255(191, 239, 62), nil, nil, true)
				ui.endRotation(-45,vec2(-1,-1))
				ui.beginRotation()
				ui.drawImage(meter,start + winz_m,winz - winz_m, rgb.from0255(251, 191, 114), nil, nil, true)
				ui.endRotation(135,vec2(1,1))

				--nos ico
				ui.beginRotation()
				ui.drawImage(shiftup, vec2(0,0), vec2(32,32) * resizething:get(winz.x), rgb.from0255(191, 239, 62), nil, nil, true)
				ui.endRotation(50, vec2(90,411.5) * resizething:get(winz.x))
				ui.drawImage(N20_ICON, vec2(32,410) * resizething:get(winz.x), vec2(117,410+64+30) * resizething:get(winz.x), rgb.from0255(191, 239, 62), nil, nil, true)

				--slomo ico
				ui.beginRotation()
				ui.drawImage(shiftup, vec2(0,0),vec2(32,32) * resizething:get(winz.x), rgb.from0255(251, 191, 114), nil, nil, true)
				ui.endRotation(230, vec2(390,68) * resizething:get(winz.x))
				ui.drawImage(PERSUIT_ICON, vec2(400,16) * resizething:get(winz.x), vec2(420+64,16+64) * resizething:get(winz.x), rgb.from0255(251, 191, 114), nil, nil, true)
			end)
		end
	else
		ui.transparentWindow("##catfunny", TachoPos,Tachosize, function ()
			local winz = ui.windowSize()
			local winz_m = vec2(winz.x/32,winz.y/32)
	
			ui.drawImage(cattach, start, Tachosize * 1.859, hud.tachocolor, nil, nil, true)
			ui.drawImage(catRPM, winz_m * 0.5, Tachosize - winz_m * 0.5, hud.rpmcolor, nil, nil, true)
			ui.beginRotation()
			ui.drawImage(catneedle , start, Tachosize, hud.needlecolor, nil, nil, true)
			ui.endRotation(-catrpmlut:get(rpmsmoothed)+90)
			
	
			ui.pushDWriteFont(catfont)
			ui.dwriteDrawText(speed,100 * resized, catspeed * resized ,num_color)
			ui.dwriteDrawText("KMH",50 * resized, vec2(320,350) * resized ,num_color)
			if gear < 0 then
				ui.dwriteDrawText("R", 75 * resized, catgear * resized, num_color)--have R when reverse
			elseif gear == 0 then
				ui.dwriteDrawText("N", 75 * resized, catgear * resized, num_color)
			else
				ui.dwriteDrawText(gear, 75 * resized, catgear * resized, num_color)--show numbers when not in reverse
			end								
			ui.popDWriteFont()
	
		end)
		if car.turboCount > 0 then
			ui.transparentWindow("##extra2", TachoPos - Tachosize/2 + vec2(0,TachoY*0.95), Tachosize, function () -- in here is a way to keep the pos for other window
				ui.drawImage(catturbo , start, Tachosize, hud.tachocolor, nil, nil, true)
				ui.drawImage(catturbolines , start, Tachosize - vec2(4,0), hud.rpmcolor, nil, nil, true)
				ui.beginRotation()
				ui.drawImage(catturboneedle , vec2(0,0), vec2(32,128) * resized, hud.needlecolor, nil, nil, true)
				ui.endPivotRotation(75-bar*3.88,vec2(16,0) * resized,vec2(128,145) * resized)--firs time using pivot lul
			end)
		end
	end
end



local mirrorbright = 0.5
function MirrorSettings()
	if ui.checkbox("Enable Mirror", hud.mirror) then
		hud.mirror = not hud.mirror
	end
	if ui.checkbox("Replace Mirror", hud.mirrorReplace) then
		hud.mirrorReplace = not hud.mirrorReplace
	end
	local mirrorBslider = ui.slider("###1", mirrorbright, 0, 1, "Thing: %.2f", 1)
	if mirrorBslider then
		mirrorbright = mirrorBslider
	end
end

mirrortestt = ac.getFolder(ac.FolderID.ACApps) .. "\\lua\\nfsmw05hud\\img\\misc\\MIRROR.dds"
mirrortestt2 = ac.getFolder(ac.FolderID.ACApps) .. "\\lua\\nfsmw05hud\\img\\misc\\MIRROR2.dds"
mirrortestt3 = ac.getFolder(ac.FolderID.ACApps) .. "\\lua\\nfsmw05hud\\img\\misc\\MIRROR3.dds"
whore = "dynamic::mirror"

function script.Mirror()
	if true then
		ac.redirectVirtualMirror(false)
		return
	end
	local simState = ac.getSim()
	if simState.isVirtualMirrorActive ~= true then
		return
	end

	local win = ac.getUI()

	if hud.mirror == true then
		ui.setCursor(vec2(0, 0))
		ui.childWindow("mirrortest", function()
			--[[
		ui.renderTexture({
			filename = 'dynamic::mirror',
			p1 = vec2(-50, 0),
			p2 = vec2(0, 150),
			color = rgbm(0.2,0.2,0.2,1),
			uv1 = vec2(1, 0),
			uv2 = vec2(-1, 1),
			blendMode = render.BlendMode.BlendAccurate,
			mask1 = mirrortestt3,
			mask1Flags =render.TextureMaskFlags.UseAlpha,
			mask1UV1 = vec2(0.004,0.02),
			mask1UV2 = vec2(1,0.8),
		})
		--]]
			if hud.mirrorReplace == true then
				return
			end
			ui.drawImage(
				whore,
				vec2(-50, 25),
				vec2(650, 225),
				rgbm(mirrorbright, mirrorbright, mirrorbright, 1),
				vec2(0, 0),
				vec2(-1, 1),
				false
			)
			ui.drawImage(mirrortestt, vec2(-50, 25), vec2(300, 225), rgbm.colors.white, vec2(0, 0), vec2(-1, 1), false)
			ui.drawImage(mirrortestt, vec2(300, 25), vec2(650, 225), false)
		end)
	end

	if hud.mirrorReplace == true then
		ac.redirectVirtualMirror(true)
		ui.transparentWindow("mirrortest", vec2(win.windowSize.x / 2 - 300, 20), vec2(600, 200), function()
			ui.renderTexture({
				filename = "dynamic::mirror",
				p1 = vec2(-50, 0),
				p2 = vec2(0, 150),
				color = rgbm(mirrorbright, mirrorbright, mirrorbright, 1),
				uv1 = vec2(1, 0),
				uv2 = vec2(-1, 1),
				blendMode = render.BlendMode,
				mask1 = mirrortestt3,
				mask1Flags = render.TextureMaskFlags.UseAlpha,
				mask1UV1 = vec2(0.004, 0.05),
				mask1UV2 = vec2(1, 0.8),
			})
			ui.drawImage(mirrortestt, vec2(-50, 0), vec2(300, 200), rgbm.colors.white, vec2(0, 0), vec2(-1, 1), false)
			ui.drawImage(mirrortestt, vec2(300, 0), vec2(650, 200), false)
		end)
	end
end



--function script.onHideMirror()
--	ac.redirectVirtualMirror(false)
--end