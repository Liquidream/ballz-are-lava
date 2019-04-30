--[[ Copyright (c) 2018, Charles Mallah ]]
-- Released with MIT License

local pairs, ipairs, type              = pairs, ipairs, type
local table, math, tonumber            = table, math, tonumber

local joystick                         = love.joystick

--local print                            = love.graphics.print
local setColorO                        = love.graphics.setColor
local setColor                         = setNormalisedColour
local rectangle                        = love.graphics.rectangle
local line                             = love.graphics.line
local circle                           = love.graphics.circle

local n255 = 0.003921568627451
function setNormalisedColour(r, g, b, a)
  return setColorO(r*n255, g*n255, b*n255, a*n255)
end
local setColor = setNormalisedColour


---------------------------------------|
--- Settings
--
---------------------------------------|

local deadzone                         = 0.5

local CONTROL_MAP = {
  
  { name = "primaryA", sources = {"button:a"} },
  { name = "secondaryX", sources = {"button:x"} },
  
  { name = "thirdB", sources = {"button:b"} },
  { name = "fourthY", sources = {"button:y"} },
  
  { name = "axis1_left", sources = {"axis:leftx-"} },
  { name = "axis1_right", sources = {"axis:leftx+"} },
  { name = "axis1_up", sources = {"axis:lefty-"} },
  { name = "axis1_down", sources = {"axis:lefty+"} },
  
  { name = "dleft", sources = {"button:dpleft"} },
  { name = "dright", sources = {"button:dpright"} },
  { name = "dup", sources = {"button:dpup"} },
  { name = "ddown", sources = {"button:dpdown"} },
  
  { name = "axis2_left", sources = {"axis:rightx-"} },
  { name = "axis2_right", sources = {"axis:rightx+"} },
  { name = "axis2_up", sources = {"axis:righty-"} },
  { name = "axis2_down", sources = {"axis:righty+"} },
  
  { name = "back", sources = {"button:back"} },
  { name = "start", sources = {"button:start"} },
  
  { name = "leftstick", sources = {"button:leftstick"} },
  { name = "rightstick", sources = {"button:rightstick"} },
  
  { name = "leftshoulder", sources = {"button:leftshoulder"} },
  { name = "rightshoulder", sources = {"button:rightshoulder"} },
  
  { name = "lefttrigger", sources = {"axis:triggerleft+"} },
  { name = "righttrigger", sources = {"axis:triggerright+"} },
  
}


---------------------------------------|
--- Globals
--
---------------------------------------|
-- Made global, so can use these routines externally
gamepads                      = {}

---------------------------------------|
--- Locals
--
---------------------------------------|

--local gamepads                         = {}
local mainGamepad                      = nil

local history                          = {}
local historyCount                     = 0
local historyMin                       = 1

local history2                         = {}
local historyCount2                    = 0
local historyMin2                      = 1

local debugButton                      = nil
local debugAxis                        = nil

local outputMax                        = 12
local outputClear                      = 0
local outputSpeed                      = 0.5
local outputSpeed2                     = 5.0


---------------------------------------|
--- Functions
--
---------------------------------------|

--
function controllerAxisPair(controller, axisNumber)
  local fineDeadzone = 0.1
  local v = controller.buttonControls["axis"..axisNumber.."_left"].value
  local xl = (v > fineDeadzone and v) or 0
  local v = controller.buttonControls["axis"..axisNumber.."_right"].value
  local xr = (v > fineDeadzone and v) or 0
  local v = controller.buttonControls["axis"..axisNumber.."_up"].value
  local yu = (v > fineDeadzone and v) or 0
  local v = controller.buttonControls["axis"..axisNumber.."_down"].value
  local yd = (v > fineDeadzone and v) or 0

  local x = -xl + xr
  local y = -yu + yd

  return { x = x, y = y }
end



---
--
function controllerAxisRaw(controller, name)
  return controller.buttonControls[name].value
end

---
--
function controllerAxisVal(controller, name)
  local v = controller.buttonControls[name].value
  return (v > deadzone and v) or 0
end

---
--
function controllerIsDown(controller, name) 
  return controller.buttonControls[name].currentDown
end

---
--
function controllerPressed(controller, name)
  local c = controller.buttonControls[name]
  return c.currentDown and not c.previousDown
end

---
--
function controllerReleased(controller, name)
  local c = controller.buttonControls[name]
  return c.previousDown and not c.currentDown
end

---
--
function changeControls(controller, controls)
  
  for i = 1, #controls do
    
    local o                = controls[i]
    local name             = o.name
    local sources          = o.sources
    
    if not controller.buttonControls[name] then
      controller.buttonControls[name] = {
                                          value              = 0,
                                          previousDown       = false,
                                          currentDown        = false,
                                        }
    end
    
    local control          = controller.buttonControls[name]
    control.sources        = {}
    
    for i = 1, #sources do
      local type, value    = sources[i]:match("(.+):(.+)")
      
      local fun            = nil
      
      if type == "axis" then
        local axis, direction = value:match("(.+)([%+%-])")
        
        if direction == "+" then 
          direction        = 1
        end
        if direction == "-" then
          direction        = -1
        end
        
        fun = function(buttonSource)
          if buttonSource.joystick then
            local v = (tonumber(axis) and buttonSource.joystick:getAxis(tonumber(axis))) or buttonSource.joystick:getGamepadAxis(axis)
            v       = v * direction
            do return (v > 0 and v) or 0 end
          end
          do return 0 end
        end
        
      elseif type == "button" then
        fun = function(buttonSource)
          if buttonSource.joystick then
            if tonumber(value) then
              do return (buttonSource.joystick:isDown(tonumber(value)) and 1) or 0 end
            else
              do return (buttonSource.joystick:isGamepadDown(value) and 1) or 0 end
            end
          end
          do return 0 end
        end
        
      elseif type == "hat" then
        fun = function(buttonSource)
          if buttonSource.joystick then
            index, direction = value:match("(%d)(.+)")
            if buttonSource.joystick:getHat(index) == direction then
              do return 1 end
            end
          end
          do return 0 end
        end
        
      end
      
      table.insert(control.sources, fun)
    end
    
  end
end

---
--
function updateControllers(dt)
  
  for i = 1, #gamepads do
    
    local active           = false
    local controller       = gamepads[i]
    local buttonControls   = controller.buttonControls
    for _, control in pairs(buttonControls) do
      for i = 1, #control.sources do
        if control.sources[i](controller) > deadzone then
          active = true
          do break end
        end
      end
    end
    
    if active then 
      controller.active          = active
    end
    
    if not controller.active then 
      do return false end
    end
    
    for _, control in pairs(buttonControls) do
      control.value        = 0
      
      local sources        = control.sources
      for i = 1, #sources do
        control.value      = control.value + sources[i](controller)
      end
      
      if control.value > 1 then 
        control.value      = 1
      end
      
      control.previousDown = control.currentDown
      control.currentDown  = control.value > deadzone
    end
  
  end
  
 
end

---
--
function love.gamepadpressed(joystick, button)  
  debugButton              = button  
end

---
--
function love.gamepadaxis(joystick, axis, value)  
  debugAxis                = axis  
end

---
--
function updateControllersDebug(dt)
  
  for i = 1, #gamepads do
    
    local controller       = gamepads[i]
    local buttonControls   = controller.buttonControls
    
    for i = 1, #CONTROL_MAP do
      local name    = CONTROL_MAP[i].name
      
      if controllerPressed(controller, name) then
        historyCount            = historyCount + 1
        history[historyCount]   = { b = name.." [o]", t = 1 }
      end
      
      if controllerReleased(controller, name) then
        historyCount            = historyCount + 1
        history[historyCount]   = { b = name.." [  ]", t = 1 }
      end
      
      if controllerIsDown(controller, name) then
        historyCount2           = historyCount2 + 1
        history2[historyCount2] = { b = name.." [+]", t = 1 }
      end
      
    end
    
  end
  
  -- Pressed Released input test
  local startL    = math.max(historyCount - outputMax, historyMin)
  local endL      = historyCount
  for i = startL, endL do
    local this    = history[i]
    this.t        = this.t - (dt * outputSpeed)
    if this.t < 0 then
      history[i]  = nil
      historyMin  = i + 1
    end
  end
  
  -- Is down input test
  local startL    = math.max(historyCount2 - outputMax, historyMin2)
  local endL      = historyCount2
  for i = startL, endL do
    local this    = history2[i]
    this.t        = this.t - (dt * outputSpeed2)
    if this.t < 0 then
      history2[i] = nil
      historyMin2 = i + 1
    end
  end
  
  
end

---
--
function drawControllersDebug()
  
  -- Draw debug for controller 1
  if mainGamepad ~= nil and mainGamepad ~= nil then
    
    local mainX           = 400
    local mainY           = 300
    
    local buttonX         = 625
    local buttonY         = 200
    local buttonShift     = 30
      
    local buttonMiscX     = 500
    local buttonMiscY     = 75
    local buttonMiscShift = 30

    local inputTextX      = 100
    local inputTextY      = mainY

    local inputText2X     = 650
    local inputText2Y     = mainY

    local boxSize         = 300
    local boxSize2        = boxSize * 0.5

    local x, y            = mainX, mainY
    
    -- Centre graph
    setNormalisedColour(230, 40, 80, 110)
    circle("line", x, y, boxSize2, boxSize2)
  
    -- Axis 1 dot as input
    x, y = mainX, mainY
    setNormalisedColour(230, 40, 80, 240)
    x = x + boxSize2 * controllerAxisVal(mainGamepad, "axis1_right")
    x = x - boxSize2 * controllerAxisVal(mainGamepad, "axis1_left")
    y = y + boxSize2 * controllerAxisVal(mainGamepad, "axis1_down")
    y = y - boxSize2 * controllerAxisVal(mainGamepad, "axis1_up")
    if controllerIsDown(mainGamepad, "leftstick") then
      circle("fill", x, y, 16)
    else
      circle("line", x, y, 8)
    end
    
    -- Axis 1 dot as raw
    x, y = mainX, mainY
    setNormalisedColour(230, 40, 80, 150)
    x = x + boxSize2 * controllerAxisRaw(mainGamepad, "axis1_right")
    x = x - boxSize2 * controllerAxisRaw(mainGamepad, "axis1_left")
    y = y + boxSize2 * controllerAxisRaw(mainGamepad, "axis1_down")
    y = y - boxSize2 * controllerAxisRaw(mainGamepad, "axis1_up")
    if controllerIsDown(mainGamepad, "leftstick") then
      circle("fill", x, y, 16)
    else
      circle("line", x, y, 8)
    end
    
    -- Axis 2 dot as input
    x, y = mainX, mainY
    setNormalisedColour(40, 130, 255, 240)
    x = x + boxSize2 * controllerAxisVal(mainGamepad, "axis2_right")
    x = x - boxSize2 * controllerAxisVal(mainGamepad, "axis2_left")
    y = y + boxSize2 * controllerAxisVal(mainGamepad, "axis2_down")
    y = y - boxSize2 * controllerAxisVal(mainGamepad, "axis2_up")
    if controllerIsDown(mainGamepad, "rightstick") then
      circle("fill", x, y, 8)
    else
      circle("line", x, y, 4)
    end
    
    -- Axis 2 dot as raw
    x, y = mainX, mainY
    setNormalisedColour(40, 130, 255, 150)
    x = x + boxSize2 * controllerAxisRaw(mainGamepad, "axis2_right")
    x = x - boxSize2 * controllerAxisRaw(mainGamepad, "axis2_left")
    y = y + boxSize2 * controllerAxisRaw(mainGamepad, "axis2_down")
    y = y - boxSize2 * controllerAxisRaw(mainGamepad, "axis2_up")
    if controllerIsDown(mainGamepad, "rightstick") then
      circle("fill", x, y, 8)
    else
      circle("line", x, y, 4)
    end
    
    -- Dpad
    x, y = mainX, mainY
    setNormalisedColour(30, 130, 130, 110)
    rectangle("line", x - boxSize2, y - boxSize2, boxSize, boxSize)
    setNormalisedColour(30, 130, 130, 240)
    if controllerIsDown(mainGamepad, "dright") then
      x = mainX + boxSize2
      y = mainY
      circle("fill", x, y, 8)
    elseif controllerIsDown(mainGamepad, "dleft") then
      x = mainX - boxSize2
      y = mainY
      circle("fill", x, y, 8)
    end
    if controllerIsDown(mainGamepad, "dup") then
      x = mainX
      y = mainY - boxSize2
      circle("fill", x, y, 8)
    elseif controllerIsDown(mainGamepad, "ddown") then
      x = mainX
      y = mainY + boxSize2
      circle("fill", x, y, 8)
    end
    
    -- Main buttons
    setNormalisedColour(30, 130, 130, 110)
    rectangle("line", buttonX - buttonShift, buttonY - buttonShift, buttonShift * 2, buttonShift * 2)    
    setNormalisedColour(30, 200, 30, 240)
    x = buttonX
    y = buttonY + buttonShift
    if controllerIsDown(mainGamepad, "primaryA") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end
    setNormalisedColour(30, 30, 200, 240)
    x = buttonX - buttonShift
    y = buttonY
    if controllerIsDown(mainGamepad, "secondaryX") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end    
    setNormalisedColour(200, 30, 30, 240)
    x = buttonX + buttonShift
    y = buttonY
    if controllerIsDown(mainGamepad, "thirdB") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end    
    setNormalisedColour(200, 200, 30, 240)
    x = buttonX
    y = buttonY - buttonShift
    if controllerIsDown(mainGamepad, "fourthY") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end
    
    setNormalisedColour(30, 130, 130, 240)
    rectangle("line", buttonMiscX - buttonMiscShift, buttonMiscY - buttonMiscShift, buttonMiscShift * 2, buttonMiscShift * 2)    
    
    -- Triggers  
    setNormalisedColour(250, 250, 250, 240)
    x = buttonMiscX - buttonMiscShift
    y = buttonMiscY
    local t = controllerAxisRaw(mainGamepad, "lefttrigger")
    if t > 0 then
      circle("fill", x, y, 12 * t + 2)
    else
      circle("line", x, y, 12 * t + 2)
    end
    setNormalisedColour(250, 250, 250, 240)
    x = buttonMiscX + buttonMiscShift
    y = buttonMiscY
    local t = controllerAxisRaw(mainGamepad, "righttrigger")
    if t > 0 then
      circle("fill", x, y, 12 * t + 2)
    else
      circle("line", x, y, 12 * t + 2)
    end
    
    -- Misc buttons
    setNormalisedColour(200, 200, 200, 240)
    x = buttonMiscX - buttonMiscShift
    y = buttonMiscY - buttonMiscShift
    if controllerIsDown(mainGamepad, "leftshoulder") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end
    setNormalisedColour(200, 200, 200, 240)
    x = buttonMiscX + buttonMiscShift
    y = buttonMiscY - buttonMiscShift
    if controllerIsDown(mainGamepad, "rightshoulder") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end
    
    setNormalisedColour(50, 50, 50, 240)
    x = buttonMiscX + buttonMiscShift
    y = buttonMiscY + buttonMiscShift
    if controllerIsDown(mainGamepad, "start") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end    
    setNormalisedColour(50, 50, 50, 240)
    x = buttonMiscX - buttonMiscShift
    y = buttonMiscY + buttonMiscShift
    if controllerIsDown(mainGamepad, "back") then
      circle("fill", x, y, 12)
    else
      circle("line", x, y, 12)
    end
    
    -- Controller Data
    local ypos   = 20
    setNormalisedColour(255, 255, 255, 255)
    love.graphics.print(mainGamepad.joystick:getName(), 10, ypos)
    ypos       = ypos + 20
    if mainGamepad.joystick:isGamepad() == true then
      love.graphics.print("is a gamepad", 10, ypos)
    else
      love.graphics.print("is not a gamepad", 10, ypos)
    end
    ypos       = ypos + 20
    if mainGamepad.joystick:isConnected() == true then
      love.graphics.print("is connected", 10, ypos)
    else
      love.graphics.print("is not connected", 10, ypos)
    end
    ypos       = ypos + 20
    love.graphics.print("GUID: "..mainGamepad.joystick:getGUID() .. " / ID: "..mainGamepad.joystick:getID(), 10, ypos)
    ypos       = ypos + 20
    love.graphics.print("buttons: "..mainGamepad.joystick:getButtonCount(), 10, ypos)
    ypos       = ypos + 20
    love.graphics.print("hats: "..mainGamepad.joystick:getHatCount(), 10, ypos)
    ypos       = ypos + 20
    love.graphics.print("axes: "..mainGamepad.joystick:getAxisCount(), 10, ypos)
    if debugButton ~= nil then
      ypos       = ypos + 20
      love.graphics.print("* last button: "..debugButton, 10, ypos)
    end      
    if debugAxis ~= nil then
      ypos       = ypos + 20
      love.graphics.print("* last axis: "..debugAxis, 10, ypos)
    end
    
    -- Pressed Released input test
    local startL = math.max(historyCount - outputMax, historyMin)
    local endL   = historyCount
    local xpos   = inputTextX
    ypos         = inputTextY    
    setNormalisedColour(130, 30, 100, 255)
    love.graphics.print("PRESSED / RELEASED", xpos-20, ypos-5)    
    for i = startL, endL do
      local this = history[i]
      ypos       = ypos + 20
      setNormalisedColour(255, 255, 255, 255 * this.t)  
      love.graphics.print(this.b, xpos, ypos)
    end
    
    -- Is down input test
    startL       = math.max(historyCount2 - outputMax, historyMin2)
    endL         = historyCount2
    xpos         = inputText2X
    ypos         = inputText2Y
    setNormalisedColour(130, 30, 100, 255)
    love.graphics.print("HELD DOWN", xpos-20, ypos-5)
    for i = startL, endL do
      local this = history2[i]
      ypos       = ypos + 20
      setNormalisedColour(255, 255, 255, 255 * this.t)  
      love.graphics.print(this.b, xpos, ypos)
    end
  
  else
    
    local ypos   = 20
    setNormalisedColour(255, 255, 255, 255)
    love.graphics.print("No game-pads", 10, ypos)
    
  end
  
end

---
--
function connectControllers(contolMap)
  local joy            = joystick.getJoysticks()
  gamepads             = {}
  
  for i = 1, #joy do

    print("connectControllers:"..i)
    
    -- Where 
    gamepads[i]       = { 
                           joystick          = joy[i], -- Reference to the Love2d joystick object
                           
                           active            = nil,
                           
                           buttonControls    = {},
                          
                         }
    
    changeControls(gamepads[i], contolMap)
    
  end
  
end

---
--
function checkControllers(controlMap)
  local joy            = joystick.getJoysticks()
  local nJoy           = #joy
  
  print("njoy = "..nJoy)
  print("type= = "..type(joy[1]))
  print("#gamepads = "..#gamepads)

  if nJoy > 0 and (gamepads == nil or nJoy > #gamepads) then    
    
    connectControllers(controlMap or CONTROL_MAP)   
    
    -- Link the main controller input to controller 1
    if gamepads[1] ~= nil then    
      mainGamepad      = gamepads[1]   
    end
    
  -- (PN) changed from the original, which was "if #gamepads > 0..."
  elseif #gamepads == 0 then
    print("no gamepads...")

    gamepads           = {}
    mainGamepad        = nil
    
  end
  
end

---
--
function love.joystickremoved(joystick)
  checkControllers()
end

---
--
function love.joystickadded(joystick)
  checkControllers()
end
