--#region Sliders

--[[
	first return is value, second return is if it has changed
	i had rare game crashes when i used the first return as 
	a "has it changed" return so its not as reliable? 
--]]

-- Slider 1
local storage = ac.storage({ slider = 0 }) --ac.storage({}) --to keep changes, do not have it in script.* or it will generate a new table every dt
local firstslider, firstsliderchanged = ui.slider("###1", storage.slider, 0, 10, "Thing: %.0f", 1)
if changed then
	storage.slider = firstslider --assign slider value into a table key 
end

-- Slider 2
local storage2 = 35
local slider = ui.slider("###1", storage2, 0, 100, "Thing: %.0f", 1)
if slider then
	storage2 = slider
end

--#endregion

--------------------------------------------------

--#region Checkbox

--Checkbox 1
local Checkbox = refbool(true/false)
ui.checkbox('Checkbox', Checkbox.value)
if Checkbox.value == true then
	--thing
end

-- Checkbox 2
-- this one ive been using 24/7 taken from csp lua sdk
if ui.checkbox('My checkbox', myFlag) then
	myFlag = not myFlag
end
if myflag then
end

--#endregion

--------------------------------------------------

--#region Buttons

-- most basic button
if ui.button("Button ONE") then
	--single press = once sent, see flags for double click
	ac.sendChatMessage("button has send this message")
end

local buttontoggle = false
--button that is like a toggle with changing text
if ui.button(
	buttontoggle == true and "This button is ON" or --when button1 is true it shows top text
	buttontoggle == false and "this button is OFF") -- if false shows bottom
	--always have the true/false check first (i forgot that once and wondered why it didn work)
	then
		buttontoggle = not buttontoggle
end

--#endregion

--------------------------------------------------

--#region Keybind

--to keep changes, do not have it in script.* or it will generate a new table every script.*(dt)
local key_storage = {button_value = 999, button_name = ""}
--keys cant go into the negative or be zero for csp so using them is the best answer imo


--a button that shows 3 states
if ui.button(key_storage.button_value == 0 and "Press a Key." or 								--use 0 as a "we are setting a key"
			(key_storage.button_value == 999 and "Click to Set Key" or 							--use 999 to show there is no key set
			(key_storage.button_value >= 1 and "Selected key: " .. key_storage.button_name)))	--if value above 0, show the set key name
			then key_storage.button_value = 0													--this here sets the value to 0
end 	
	
--resetting the key a.k.a. simply clearing the table
if ui.button("Reset Key") then 
	key_storage.button_value = 999	-- 999 so it shows no key is set
	key_storage.button_name = "nil"	--just something random, wont be seen anyway
end

--for the most important part
if key_storage.button_value == 0 then
	for _key_name, _key_value in pairs(ui.KeyIndex) do			--get all keys via csp ui
		if ui.keyboardButtonDown(_key_value) then 		--when a key is pressed
			key_storage.button_value = _key_value 		--store key into value into table
			key_storage.button_name = tostring(_key_name)	--and store name for the same key to show what key is selected
		end
	end
end
--#endregion

--------------------------------------------------

--#region Color Picker

--[[
	Color Picker Shortend HARD
	Ripped Straight from Paintshop
	NO color pallete
	also quite broken
	needs to be fixed ish for easy adding
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

--------------------------------------------------

--#region Execute Once

--[[
	some buttons stay true for longer than you want sometimes
	so this is a "fix", there may(will) be easier solutions
	right now for each button, it needs its own local toggle
	might look at it later for something easier
--]]

--First one
local Toggle = false
local function Tooggele()
	local Button = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
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

--Second one
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

--#endregion

--------------------------------------------------

--#region Turn ExtraA-F buttons into 1 time execute

--[[
	change car extra button to a execute once one
	instead of it being a toggle
--]]

--Main one
if car.extraA then
	--[[
		extra switches go like 
		0 = A
		1 = B
		up to 
		5 = F
	]]
	ac.setExtraSwitch(0,false)
	if car.extraA then
		-- run shit here
		print("i ran once")
	end
end

--Second one, maybe worse?
local wasPressed = false -- not inside of update function

if (car.extraB ~= wasPressed) then 
	wasPressed = not wasPressed
	if wasPressed then
		--run something here on first press
		print("i went from false to true and ran once")
	end
	if not wasPressed then
		-- or the second press
		print("i went from true to false and ran once")
	end
end

--[[
	something i will use when im desperate
	slight edit? used in old ver of controller input
	debounce taken from gt7 hud / Inori
--]]

--the gt7 part
sim = ac.getSim()
LAST_DEBOUNCE = 0
function debounceValues(func, wait)
    local now = sim.time
    if now - LAST_DEBOUNCE < wait then return end
    LAST_DEBOUNCE = now
    return func()
end

--my addition
local function Hazards()
	if ac.getCar().hazardLights == true then
		ac.setTurningLights(ac.TurningLights.None)
	elseif ac.getCar().hazardLights == false then
		ac.setTurningLights(ac.TurningLights.Hazards)
	end
end

local input = ac.isGamepadButtonPressed(4, ac.GamepadButton.Microphone)
if input then
	debounceValues(Hazards, 2500)
end

--#endregion

--------------------------------------------------

--#region Car Physics

--[[
	if car.gas < 0.01 and car.speedKmh < 10 then do "engine off" thing
--]]

--main one
local westanding = false
function script.update(dt)
	if 
	car.gas < 0.01 
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

--test thing, fucked prolly: forgot
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

--#endregion

--------------------------------------------------

--#region ways to import
local thing = ac.dirname() .. "image.dds"
local thing = ac.dirname() .. "\\folderdeeper\\image.dds"
local luathing = ac.dirname() .. "\\otherfolderinsideofapp\\thing.lua"
require(luathing)--could work?
--#endregion

--------------------------------------------------

--#region Functions that are quite useful

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

--#endregion

--------------------------------------------------

--#region Controller Translation from Gamepad to Joystick

--Gamepad ds5
ac.getGamepadAxisValue(0,0) --RT
ac.getGamepadAxisValue(0,1) --LT
ac.getGamepadAxisValue(0,2) --LS X
ac.getGamepadAxisValue(0,3) --LS Y
ac.getGamepadAxisValue(0,4) --RS X
ac.getGamepadAxisValue(0,5) --RS Y

--Joystick ds5
ac.getJoystickAxisValue(0,0) -- LS X
ac.getJoystickAxisValue(0,1) -- LS Y
ac.getJoystickAxisValue(0,2) -- RS X
ac.getJoystickAxisValue(0,5) -- RS Y
ac.getJoystickAxisValue(0,3) -- LT
ac.getJoystickAxisValue(0,4) -- RT

--#endregion