local function ObamiumHUD()
  local mem = ac.storage{
    pos=vec3(0,0,0),
    dir=vec3(0,0,0),
    vel=vec3(0,0,0),
    gear= 0,
    tyrespeed= 0,
    extraspeeder = 1
  }
  if ui.button("SavePos") or ui.keyPressed(ui.Key.Left) then
    mem.pos=ac.getCar(0).position
    mem.dir=ac.getCar(0).look
    mem.vel=ac.getCar(0).velocity
    mem.gear=ac.getCar(0).gear
  end
  ui.sameLine()
  if ui.button("LoadPos") or ui.keyPressed(ui.Key.Right) then
    physics.setCarPosition(0,mem.pos,-mem.dir)
    physics.setCarVelocity(0,mem.vel * vec3(mem.extraspeeder, 0,mem.extraspeeder))
      if mem.extraspeeder == 1 then
        physics.engageGear(0,mem.gear)
      else
      physics.engageGear(0,ac.getCar(0).gearCount)
    end
  ui.sameLine()
  end
  local extraspeed = ui.slider('##' .. 'Speed', mem.extraspeeder, 0, 10, 'Speed' .. ': %.1f')
  if extraspeed then
    mem.extraspeeder = extraspeed
  end
ui.text("\n")
ui.sameLine()
  if ui.button("Ai ON") then
    physics.setCarAutopilot(true)
  end
  ui.sameLine()
  if ui.button("Ai OFF") then
    physics.setCarAutopilot(false)
  end
end
ui.registerOnlineExtra(ui.Icons.Crosshair, 'ExtraStuff', nil, ObamiumHUD, nil, ui.OnlineExtraFlags.Tool)