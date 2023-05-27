local car = ac.getCar()
local button = "nil"


function extrabuttons()
	ui.text("extraD on controller is on playstation button\nthis shows if i press it: " .. tostring(ac.isGamepadButtonPressed(4,ac.GamepadButton.PlayStation)))

	if ui.button(car.extraA == true and "extraA on" or car.extraA == false and "extraA off",vec2(77,22))then
		if car.extraA == true then
			ac.setExtraSwitch(0,false)
		else
			ac.setExtraSwitch(0,true)
		end
	end ui.sameLine(0,2)

	if ui.button(car.extraB == true and "extraB on" or car.extraB == false and "extraB off",vec2(77,22))then
		if car.extraB == true then
			ac.setExtraSwitch(1,false)
		else
			ac.setExtraSwitch(1,true)
		end
	end 

	if ui.button(car.extraC == true and "extraC on" or car.extraC == false and "extraC off",vec2(77,22))then
		if car.extraC == true then
			ac.setExtraSwitch(2,false)
		else
			ac.setExtraSwitch(2,true)
		end
	end ui.sameLine(0,2)

	if ui.button(car.extraD == true and "extraD on" or car.extraD == false and "extraD off",vec2(77,22))then
		if car.extraD == true then
			ac.setExtraSwitch(3,false)
		else
			ac.setExtraSwitch(3,true)
		end
	end 
	
	if ui.button(car.extraE == true and "extraE on" or car.extraE == false and "extraE off",vec2(77,22))then
		if car.extraE == true then
			ac.setExtraSwitch(4,false)
		else
			ac.setExtraSwitch(4,true)
		end
	end ui.sameLine(0,2)

	if ui.button(car.extraF == true and "extraF on" or car.extraF == false and "extraF off",vec2(77,22))then
		if car.extraF == true then
			ac.setExtraSwitch(5,false)
		else
			ac.setExtraSwitch(5,true)
		end
	end

end