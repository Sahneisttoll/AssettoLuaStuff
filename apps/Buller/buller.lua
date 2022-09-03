ui.setAsynchronousImagesLoading(true)

  function script.Draw3D(dt)
    ac.debug('AI controlled', ac.getCar(0).isAIControlled)
    ac.debug('AI controlled', ac.getCar(0).isAIControlled)
  end




local function tab1()
  ui.text("1. Gas:      "..tostring(math.floor(100 * ac.getCar(0).gas)))
  ui.text("1. Breaks:   "..tostring(math.floor(100 * ac.getCar(0).brake)))
  ui.text("\n")
  ui.text("2. Extra E:  "..tostring(ac.getCar(0).extraE))
  ui.text("2. Extra F:  "..tostring(ac.getCar(0).extraF))
  ui.text("u on unkown?: "..tostring(ac.InputMethod["Unknown"]))
  ui.text("u on Wheel? : "..tostring(ac.InputMethod["Wheel"]))
  ui.text("u on Gamepad? : "..tostring(ac.InputMethod["Gamepad"]))
  ui.text("u on Crack? : "..tostring(ac.InputMethod.AI))
  --ui.button("AI ON".. ac.InputMethod{4})

--ac.InputMethod()
  --ui.text('AI level: '..tostring(ac.getCar(1).aiLevel))
  --ui.text('AI aggression: '..tostring(ac.getCar(1).aiAggression))
end

local function tab2()

  local ref = refnumber(1)
  if ui.slider("name", ref.value , 0, 100,"%.3f", 2) then
    ui.text("moved")
  end
end

local function tab3()
  ui.text('TAB 1')
  ui.text('physics late: '..ac.getSim().physicsLate)
  ui.text('CPU occupancy: '..ac.getSim().cpuOccupancy)
  ui.text('CPU time: '..ac.getSim().cpuTime)
end


-- ac.onChatMessage(function (message, carIndex, sessionID)
--   ac.log(string.format('Message `%s` from %s, sessionID=%s, filtering: %s', message, carIndex, sessionID, message:match('ass') ~= nil))
--   if message:match('damn') ~= nil and carIndex ~= 0 then
--     -- no swearing on my christian server
--     return true
--   end
-- end)


local mem = ac.storage{
  pos=vec3(0,0,0),
  dir=vec3(0,0,0)
}


function script.windowMain(dt)


  pos=ac.getCar(0).position
  ui.text(mem.pos)
  if ui.button('Save pos') then
    mem.pos=ac.getCar(0).position
   end
  if ui.button('Go to pos') then
    physics.setCarPosition(0,mem.pos,vec3(0,1,0))
  end


  ui.text('Hello World! First Lua app is here')




  if ui.checkbox('Ayo', Shit ) then
    physics.setGripDecrease(0, ac.Wheel.All, 1)
    Shit = not Shit
  end





  ui.tabBar('someTabBarID', function ()
    ui.tabItem('Checks', tab1)
    ui.tabItem('Gay', tab2)
    ui.tabItem('Phy', tab3)
  end)
end

function script.update(dt)
end