--[[
this whole ass file is just  so i dont have to dig 
thru my random shit and figure out how i made it again
--]]

--#region [[Sliders to Remember]]
local storage = ac.storage({ slider = 0 }) --ac.storage({}) --to keep changes, do not have it in script.* or it will generate a new table every dt
local firstslider, firstsliderchanged = ui.slider("###1", storage.slider, 0, 10, "Thing: %.0f", 1)
if changed then
	storage.slider = firstslider --assign slider value into a table key 
end

--or
local storage2 = 35
local slider = ui.slider("###1", storage2, 0, 100, "Thing: %.0f", 1)
if slider then
	storage2 = slider
end
--#endregion

--#region [[Checkboxes/Buttons]]

--[[Checkboxes]]
-- not in functions
local Checkbox = refbool(true/false)

-- in functions
ui.checkbox('Checkbox', Checkbox)
-- then to turn on with button do inside
if Checkbox.value == true then

end

-- or this one ive been using 24/7 taken from csp lua sdk
if ui.checkbox('My checkbox', myFlag) then
	myFlag = not myFlag
end
if myflag then
end


--[[Buttons]]
--button that acts like a toggle
local button1 = true
local button2 = refbool(true)
if ui.button("Button") then
	--acts like a toggle for things
	button1 = not button1 
	button2.value = not button2.value
end
--advanced version of above
if ui.button(
	button1 == true and "This button is ON" or --when button1 is true it shows top text
	button1 == false and "this button is OFF") -- if false shows bottom
	--always have the true/false check first (i forgot that once and wondered why it didn work)
	then
	 button1 = not button1 
end

if ui.button("Button2") then
	--single press = once sent, with flags this can be a double click
	ac.sendChatMessage("button has send this message")
end

--#endregion

--#region [[Keybind Thing]]

	--to keep changes, do not have it in script.* or it will generate a new table every script.*(dt)
	local keybrd = {value = -1, name = ""}
	--keys cant go into the negative or be zero for csp so using them is the best answer imo

--a button that shows 3 states

if ui.button(keybrd.value == 0 and "Press a Key." or 					--use 0 as a "we are setting a key"
			(keybrd.value == -1 and "Click to Set Key" or 				--use -1 to show there is no key set
			(keybrd.value >= 1 and "Selected key: " .. keybrd.name)))	--if value above 0, show the set key name
			then keybrd.value = 0										--this here sets the value to 0
end 	
	
	--resetting the key a.k.a. simply clearing the table
if ui.button("Reset Key") then 
	keybrd.v = -1		-- -1 so it shows no key is set
	keybrd.n = "NIX"	--just something random, wont be seen anyway
end

--for the most important part
if keybrd.value == 0 then
	for key, value in pairs(ui.KeyIndex) do		--get all keys via csp ui
		if ui.keyboardButtonDown(value) then 	--when a key is pressed
			keybrd.value = value 				--store key into value into table
			keybrd.name = tostring(key)			--and store name for the same key to show what key is selected
		end
	end
end
--#endregion

--#region [[Color Picker]]

--[[
Color Picker Shortend HARD
Ripped Straight from Paintshop
NO color pallete
--]]

local stored = ac.storage({
	color = rgbm(0, 0.2, 1, 0.5),
})

local editing = false
local colorFlags = bit.bor(
	ui.ColorPickerFlags.NoAlpha,
	ui.ColorPickerFlags.NoSidePreview,
	ui.ColorPickerFlags.PickerHueWheel,
	ui.ColorPickerFlags.DisplayHex)

local function ColorBlock(key)
	key = key or "color"
	local col = stored[key]:clone()
	ui.colorPicker("##color", col, colorFlags)
	if ui.itemEdited() then
		stored[key] = col
		editing = true
	elseif editing and not ui.itemActive() then
		editing = false
	end
	ui.newLine()
end
--#endregion

--#region [[One time Press for Controller/Car]]

--bruh
local Toggle = false
local function Tooggele()
	local Button = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
	local Button = ac.isKeyDown(ac.KeyIndex.LeftButton)
	local Button = ac.isJoystickButtonPressed(63254,12903)
	local Button = ui.keyPressed(ui.Key.Tab)
	local Button = ui.keyboardButtonDown(ui.KeyIndex.Menu)
	local Button = ui.keyboardButtonReleased(ui.KeyIndex.F4)
	--does magic that the button is only pressed once
	if Button == Toggle then
		return
	end

	--do things in here
	if Button == true then
		-- things that should run should be in here
	end
	--does magic that the button is only pressed once
	Toggle = Button
end


--better?? but not as good as
local OnlyOnce = {
	Toggle = false,
	Press = function(self,Button)
		if Button == self.Toggle then
			return
		end
		if Button == true then
			print(ui.frameCount().."|1")
		end
		self.Toggle = Button
	end
}
--below

--test2
local Toggle = false
local function Fuck(INPUT)
	if INPUT == Toggle then return end
	if INPUT == true then
		print("bruuh")
	end
	Toggle = INPUT
end

local Button = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
Fuck(Button)

--test2


-- taken from gt7 hud / Inori
sim = ac.getSim()
--the gt7 part
LAST_DEBOUNCE = 0
function debounceValues(func, wait)
    local now = sim.time
    if now - LAST_DEBOUNCE < wait then return end
    LAST_DEBOUNCE = now
    return func()
end
--the gt7 part

--my part
local function Hazards()
	if ac.getCar().hazardLights == true then
		ac.setTurningLights(ac.TurningLights.None)
	elseif ac.getCar().hazardLights == false then
		ac.setTurningLights(ac.TurningLights.Hazards)
	end
end

local input = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
local input2 = ac.isGamepadButtonPressed(4, ac.GamepadButton.X)


if input and not input2 then
	debounceValues(Hazards, 2500)
end
if input2 and not input then
	debounceValues(Hazards, 2500)
end
--my part
-- taken from gt7 hud / Inori

--#endregion

--#region [[Car Physics thing]]
-- 	if car.gas < 0.01 and car.speedKmh < 10 then do "engine off" thing
--testthing 
local StandingTurnoff = {
	Standing = false,
	try = function(self,gas,speed)
		if gas < 0.01 and speed < 10 then
			setTimeout(
				function () self.Standing = true end,
				3, --delay
				"UniqueKey"
			) --UniqueKey for clearing
		elseif gas > 0.01 then
			clearTimeout("UniqueKey")
			self.Standing = false
		end
		if self.Standing == true then
			ac.accessCarPhysics().clutch = 0
			ac.setEngineRPM(ac.getCar(0).rpm - (15))
		end
	end
}
StandingTurnoff:try(ac.getCar(0).gas,ac.getCar(0).speedKmh)
--testthing 

--real thing 
local westanding = false
function script.update(dt)
	ac.debug("a",dt * 4500)
	if car.gas < 0.01 
	and car.speedKmh < 10 
	then
	  setTimeout(
	   function () westanding = true end,
	   3, --delay
	   "UniqueKey") --UniqueKey for clearing
	elseif car.gas > 0.01 then
		clearTimeout("UniqueKey")
		westanding = false
	end

	if westanding == true then
		ac.accessCarPhysics().clutch = 0
		ac.setEngineRPM(car.rpm - (15))
	end
end
--real thing 
--#endregion

--#region [[for importing images or other]]
local thing = ac.dirname() .. "image.dds"
local thing = ac.dirname() .. "\\folderdeeper\\image.dds"
local luathing = ac.dirname() .. "\\otherfolderinsideofapp\\thing.lua"
require(luathing)--could work?
--#endregion


local function interp(x1,x2,value,y1,y2)
	return math.lerp(y1,y2,math.lerpInvSat(value,x1,x2))
end


local function lookAt(origin,target)
	if origin ~= nil and target ~= nil then
		local zaxis = vec3():add(target - origin):normalize()
		local xaxis = zaxis:clone():cross(vec3(0, 1, 0)):normalize()
		local yaxis = xaxis:clone():cross(zaxis):normalize()
		local viewMatrix = mat4x4(
		vec4(xaxis.x, xaxis.y, xaxis.z, -xaxis:dot(origin)),
		vec4(yaxis.x, yaxis.y, yaxis.z, -yaxis:dot(origin)),
		vec4(zaxis.x, zaxis.y, zaxis.z, -zaxis:dot(origin)),
		vec4(0, 1, 0, 1))
		-- viewMatrix.look
		-- viewMatrix.side
		return viewMatrix
	end
end


