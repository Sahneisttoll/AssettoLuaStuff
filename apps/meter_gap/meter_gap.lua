---@diagnostic disable: lowercase-global, param-type-mismatch

local settings = ac.storage{
	debugText = false,
	noailinelol = false
}


	-- always needs to be updated
function script.update()
end

	-- stuff needed 
local sim = ac.getSim()
local t_l = sim.trackLengthM --track_length



function script.metergapMain()
	if settings.debugText == true then
		DebugText()
	else
		if ac.hasTrackSpline() == true then
			ui.text("LOL: ")
			local f_c = ac.getCar(sim.focusedCar) -- focused_car
			local f_c_m = t_l * ac.worldCoordinateToTrackProgress(f_c.position) -- focused car position in meters
			ui.text("me: ".. math.round(f_c_m,0))


			for i = 1, sim.carsCount - 1 do
				local r_c = ac.getCar(i)
				local r_c_m = t_l * ac.worldCoordinateToTrackProgress(r_c.position)
				ui.text("LOL: ".. math.round(r_c_m,0))
			end
		end
	end
end














function script.gapSettings(dt)
	ui.text("Hello to Settings\n ")
	if ui.checkbox("Replace with Debug text", settings.debugText) then
		settings.debugText = not settings.debugText
	end
	if settings.debugText == true then
		if ui.checkbox("i have no ai line overwrite", settings.noailinelol) then
			settings.noailinelol = not settings.noailinelol
		end

	end
	ui.newLine(0)
end
-- debug shit down here
function DebugText()

	local d_sim = ac.getSim()
	local t_length = d_sim.trackLengthM
	local f_car = ac.getCar(d_sim.focusedCar)


	if settings.noailinelol == true then
		ui.text("is there a spline?:	" .. tostring("WERE DOOOMED"))
		else
	ui.text("is there a spline?:	" .. tostring(ac.hasTrackSpline()))
	ui.text("Track Length:	" .. tostring(t_length))
	end

	if ac.hasTrackSpline() == true and settings.noailinelol == false then
		ui.text("wuzkung we have ai line")
		local f_pos = ac.worldCoordinateToTrackProgress(f_car.position)
		ui.text("focused car:	" .. math.round(f_pos * 100, 1) .. "%")

		local f_meters = t_length * f_pos
		ui.text("focused car:	" .. math.round(f_meters, 0) .. " m")

		for i = 1, d_sim.carsCount - 1 do
			local r_car = ac.getCar(i)
			local r_name = ac.getDriverName(i)
			local r_pos = ac.worldCoordinateToTrackProgress(r_car.position)
			local r_meters = t_length * r_pos
			local distance =   f_meters - r_meters
			--infront of me
			if r_car.isConnected == true and r_pos >= f_pos then
				ui.text("infront:	".. r_name.. " ".. math.round(r_pos * 100, 1).. "%|".. math.round(r_meters, 0).. "m|" .. math.round(distance,0).."m")
			end

		end
		ui.text("me")
		for i = 1, d_sim.carsCount - 1 do
			local r_car = ac.getCar(i)
			local r_name = ac.getDriverName(i)
			local r_pos = ac.worldCoordinateToTrackProgress(r_car.position)
			local r_meters = t_length * r_pos
			local distance =   f_meters - r_meters
			--behind me
			if r_car.isConnected == true and r_pos <= f_pos then
				ui.text("behind:	".. r_name.. " ".. math.round(r_pos * 100, 1).. "%|".. math.round(r_meters, 0).. "m|" .. math.round(distance,0).."m")
			end
		end
	else
		ui.text("wuzhung we dont have ai line\nLETS TRY ANYWAY")
		local f_pos = f_car.position
		ui.text("my POSITIIIION: ".. tostring(f_pos))

		for i = 1, d_sim.carsCount - 1 do
			local r_pos = ac.getCar(i).position
			local r_name = ac.getDriverName(i)
			local r_pos_that_far_away = math.distance(f_pos, r_pos)
			--ui.text("Enemy ("..r_name.."): " .. tostring(r_pos))
			ui.text("Enemy Distance: " .. math.round(r_pos_that_far_away,2).."m")
		end
	end
end