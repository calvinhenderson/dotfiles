-- Scrolls the mouse when the WWW back button is held

local scrollButton = 3
local middleButton = 4
local deferred = false
local dragging = false
local speed_x = 1.5
local speed_y = -3

local zooming = false
local zoom_speed = 0.1
local is_pressed = 0

local types = hs.eventtap.event.types
local props = hs.eventtap.event.properties

function isScrolling()
  buttons = hs.mouse.getButtons()
  return buttons[scrollButton] == true
end

function scroll_dt(drag_event)
  -- We aren't just pressing the button
  deferred = false
  dragging = true
  local event = nil

  -- Get the current mouse position
  local mouse_pos = hs.mouse.absolutePosition()

  -- Calculate the scrolling offsets
  local dx = -drag_event:getProperty(props['mouseEventDeltaX'])
  local dy = drag_event:getProperty(props['mouseEventDeltaY'])

  -- Disable zooming if we let go of CMD
  zooming = hs.eventtap.checkKeyboardModifiers()['cmd']

  -- Check for modifiers so we can perform zoom gestures
  if zooming then
    local mag = -dy * zoom_speed
    event = hs.eventtap.event.newGesture('beginMagnify', mag)
  else
    -- Scroll
    event = hs.eventtap.event.newScrollEvent({ dx * speed_x, dy * speed_y }, {}, "pixel")
  end

  -- Reset the mouse position
  hs.mouse.absolutePosition(mouse_pos)

  return true, { event }
end

function middle_cb(drag_event)
  -- We aren't just pressing the button
  deferred = false

  -- Calculate the scrolling offsets
  local dx = drag_event:getProperty(props['mouseEventDeltaX'])
  local dy = drag_event:getProperty(props['mouseEventDeltaY'])

  local mouse_pos = hs.mouse.absolutePosition()

  -- Update the drag event
  local drag_event = hs.eventtap.event.newMouseEvent(types['otherMouseDragged'], mouse_pos)
  drag_event:setProperty(props['mouseEventDeltaX'], dx)
  drag_event:setProperty(props['mouseEventDeltaY'], dy)
  drag_event:setProperty(props['mouseEventButtonNumber'], 3)
  drag_event:setProperty(props['mouseEventClickState'], 1)

  if not is_pressed then
    local middle_dn_event = hs.eventtap.event.newMouseEvent(types['otherMouseDown'], mouse_pos)
    middle_dn_event:setProperty(props['mouseEventButtonNumber'], 3)
    is_pressed = middle_dn_event:getProperty(props['mouseEventNumber'])
    drag_event:setProperty(props['mouseEventNumber'], is_pressed)
    return true, { middle_dn_event, drag_event }
  else
    return true, { drag_event }
  end
end

mouseDownEvent = hs.eventtap.new({ types['otherMouseDown'] }, function(event)
  local eventButton = event:getProperty(props['mouseEventButtonNumber'])
  if eventButton == scrollButton then
    deferred = true
    zoom_level = 0
    zooming = hs.eventtap.checkKeyboardModifiers()['cmd']
    return true
  elseif eventButton == middleButton then
    deferred = true
    is_pressed = false
    return true
  end

  return false
end)

mouseUpEvent = hs.eventtap.new({ types['otherMouseUp'] }, function(event)
  local eventButton = event:getProperty(props['mouseEventButtonNumber'])
  if eventButton == scrollButton or eventButton == middleButton then
    if deferred then
      mouseDownEvent:stop()
      mouseUpEvent:stop()

      hs.eventtap.otherClick(event:location(), nil, eventButton)

      mouseDownEvent:start()
      mouseUpEvent:start()

      return true
    elseif eventButton == middleButton and is_pressed then
      local mouse_pos = hs.mouse.absolutePosition()

      local middle_up_event = hs.eventtap.event.newMouseEvent(types['otherMouseUp'], mouse_pos)
      middle_up_event:setProperty(props['mouseEventButtonNumber'], 3)
      middle_up_event:setProperty(props['mouseEventNumber'], is_pressed)
      is_pressed = false

      return true, { middle_up_event }
    end

    return false
  end

  return false
end)

mouseDragEvent = hs.eventtap.new({ types['otherMouseDragged'] }, function(event)
  local eventButton = event:getProperty(props['mouseEventButtonNumber'])
  if eventButton == scrollButton then
    return scroll_dt(event)
  elseif eventButton == middleButton then
    return middle_cb(event)
  end
end)

mouseUpEvent:start()
mouseDownEvent:start()
mouseDragEvent:start()
