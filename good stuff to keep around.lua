--[[
this whole ass file is just  so i dont have to dig 
thru my random shit and figure out how i made it again
--]]


--[[	
SLIDERS EZZ
//////////////////////////////////////////
--]]

local value = {} --ac.storage({}) --to keep changes, do not have it in script.* or it will generate a new table every dt
value.slider = 0
value.slider2 = 0
local slider , changed = ui.slider("###1", value.slider, 0, 10, "Thing: %.0f", 1)

if changed then
	value.slider2 = slider --assign slider value into a table key 
	other = slider
end

--or
local slider = ui.slider("###1", value.slider2, 0, 10, "Thing: %.0f", 1)
if slider then
	value.slider2 = slider
end
-- //////////////////////////////////////////


--[[
Different ways for Checkboxes
//////////////////////////////////////////
--]]

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
-- //////////////////////////////////////////


--[[
button to set keybinds
//////////////////////////////////////////
--]]

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
-- //////////////////////////////////////////


--[[	
Color Picker Shortend HARD
Ripped Straight from Paintshop
NO color pallete
//////////////////////////////////////////
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
-- //////////////////////////////////////////
