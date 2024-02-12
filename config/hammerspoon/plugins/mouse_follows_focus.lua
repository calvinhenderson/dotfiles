-- This plugin makes the mouse cursor
-- follow the window focus.

local function moveMouse()
  local buttons = hs.mouse.getButtons()
  local win = hs.window.focusedWindow()

  -- Only move the mouse if it is not in use
  if not buttons[1] and not buttons[2] then
    hs.mouse.absolutePosition(win:frame().center)
  end
end

local focusFilter = hs.window.filter.new(false):setDefaultFilter()
focusFilter:subscribe(hs.window.filter.windowFocused, moveMouse)

-- Add a leader combo to manually set the mouse position
require("plugins.leader_key"):bind({}, "m", moveMouse)
