function script.update(dt)
    --needed?
    local data = ac.accessCarPhysics()
    --org
    local jetActive = car.extraA
    data.controllerInputs[0] = jetActive and 1 or 0
    if jetActive then
      ac.addForce(vec3(0, 0, -1), true,   vec3(0, 0, 20000), true)
      ac.addForce(vec3(0, 0, 1), true,    vec3(0, 0, 20000), true)
    end


    --other
    local AnotherThing = car.extraB
    data.controllerInputs[0] = AnotherThing and 1 or 0
    if AnotherThing then
      ac.addForce(vec3(0, 0, -1), true, vec3(0, 0, 0), true)
      ac.addForce(vec3(0, 0, 1), true, vec3(0, 0, 0), true)
    end
    
  end