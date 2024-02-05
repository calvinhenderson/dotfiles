-- This plugin makes the mouse cursor
-- follow the window focus.

local function moveMouse()
  win = hs.window.focusedWindow()
  hs.mouse.absolutePosition(win:frame().center)
end

local focusFilter = hs.window.filter.new(false):setDefaultFilter()
focusFilter:subscribe(hs.window.filter.windowFocused, moveMouse)
