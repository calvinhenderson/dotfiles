-- This module draws a frame around the currently focused window
local frameFocusCanvas = nil
local border_width = 2

local function updateFocusFrame(_window, _app_name, _event)
  local window_frame = hs.window.frontmostWindow():frame()
  frameFocusCanvas:frame(window_frame)
  frameFocusCanvas:show()
end

local element = {
  type = "rectangle",
  action = "stroke",
  strokeColor = { red = 1.0, green = 0.0, blue = 0.0 },
  strokeWidth = border_width,
  roundedRectRadii = { xRadius = 10.0, yRadius = 10.0 }
}

frameFocusCanvas = hs.canvas.new(hs.window.frontmostWindow():frame())
frameFocusCanvas:assignElement(element, 1)
frameFocusCanvas:show()

local events = {
  hs.window.filter.windowCreated,
  hs.window.filter.windowDestroyed,
  hs.window.filter.windowFocused,
  hs.window.filter.windowFullscreened,
  hs.window.filter.windowHidden,
  hs.window.filter.windowMinimized,
  hs.window.filter.windowMoved,
  hs.window.filter.windowUnfocused,
  hs.window.filter.windowUnfullscreened,
  hs.window.filter.windowUnhidden,
  hs.window.filter.windowUnminimized,
  hs.window.filter.windowVisible,
}

frameFocusFilter = hs.window.filter.new(false)
frameFocusFilter:setDefaultFilter()
frameFocusFilter:subscribe(events, updateFocusFrame)

updateFocusFrame()
