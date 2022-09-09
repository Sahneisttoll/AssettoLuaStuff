---@diagnostic disable: lowercase-global, param-type-mismatch
ui.setAsynchronousImagesLoading(true)

  function script.Draw3D(dt)
    ac.debug('AI controlled', ac.getCar(0).isAIControlled)
  end

local function tab1()
  ui.text("1. Gas:      "..tostring(math.floor(100 * ac.getCar(0).gas)))
  ui.text("1. Breaks:   "..tostring(math.floor(100 * ac.getCar(0).brake)))
  ui.text("\n")
  ui.text("2. Extra E:  "..tostring(ac.getCar(0).extraE))
  ui.text("2. Extra F:  "..tostring(ac.getCar(0).extraF)) 
  ui.text("gay")
end

local function tab2()
  ui.text("gay")
end

local function tab3()
  ui.text("gay")
end


ac.onChatMessage(function (message, carIndex, sessionID)
  ac.log(string.format('Message `%s` from %s, sessionID=%s, filtering: %s', message, carIndex, sessionID, message:match('ass') ~= nil))
  if message:match('damn') ~= nil and carIndex ~= 0 then
    -- no swearing on my christian server
    return true
  end
end)

function script.windowMain()

  if ui.smallButton('AI on') then
    physics.setCarAutopilot(true)
  end ui.sameLine()
  if ui.smallButton('AI off') then
    physics.setCarAutopilot(false)
  end

  if ui.button("magic",vec2(250,25),ui.ButtonFlags.Repeat) then
    ui.text("bruh")
  end


  ui.text("are *physics.* allowed?\nThe answer is: " ..tostring(physics.allowed()))

  if ui.checkbox("Tabs", bruh) then
    bruh = not bruh
  end

  if bruh then
    ui.tabBar('someTabBarID', function ()
      ui.tabItem('Checks', tab1)
      ui.tabItem('Gay', tab2)
      ui.tabItem('Phy', tab3)
    end)
  end
end

function script.windowMainSettings()
  ui.text("bruh")
end