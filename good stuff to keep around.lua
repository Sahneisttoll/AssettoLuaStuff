--[[
	this whole ass file is just  so i dont have to dig 
	thru my random shit and figure out how i made it again
--]]


--[[	SLIDERS EZZ
//////////////////////////////////////////
--]]

local value = {} --to keep changes, do not have it in script.* or it will generate a new table every dt

local slidervalue,changed = ui.slider("###1", value.slider, 0, 10, "Thing: %.0f", 1)

if changed then
	value.slider = slidervalue --assign slider value into a table key 
	physics.setsomething(0, value.slider) --use either slider value or the table key
end
--[[
//////////////////////////////////////////
--]]



--[[	button to set keybinds
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
--[[
//////////////////////////////////////////
--]]