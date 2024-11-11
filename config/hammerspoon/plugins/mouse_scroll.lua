-- Scrolls the mouse when the WWW back button is held

local scrollButton = 3
local deferred = false
local speed_x = 0.1
local speed_y = -0.5

function isScrolling()
  buttons = hs.mouse.getButtons()
  return buttons[scrollButton] == true
end

mouseDownEvent = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDown }, function(event)
  local eventButton = event:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
  if eventButton == scrollButton then
    deferred = true
    return true
  end

  return false
end)

mouseUpEvent = hs.eventtap.new({ hs.eventtap.event.types.otherMouseUp }, function(event)
  local eventButton = event:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
  if eventButton == scrollButton then
    if deferred then
      mouseDownEvent:stop()
      mouseUpEvent:stop()

      hs.eventtap.otherClick(event:location(), nil, eventButton)

      mouseDownEvent:start()
      mouseUpEvent:start()

      return true
    end

    return false
  end

  return false
end)

mouseDragEvent = hs.eventtap.new({ hs.eventtap.event.types.otherMouseDragged }, function(event)
  local eventButton = event:getProperty(hs.eventtap.event.properties['mouseEventButtonNumber'])
  if eventButton == scrollButton then
    -- We aren't just pressing the button
    deferred = false

    -- Get the current mouse position
    local mouse_pos = hs.mouse.absolutePosition()

    -- Calculate the scrolling offsets
    local dx = event:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
    local dy = event:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])
    -- Scroll
    local scroll = hs.eventtap.event.newScrollEvent({ -dx * speed_x, -dy * speed_y }, {}, "line")

    -- Reset the mouse position
    hs.mouse.absolutePosition(mouse_pos)

    return true, { scroll }
  end

  return false
end)

mouseUpEvent:start()
mouseDownEvent:start()
mouseDragEvent:start()
