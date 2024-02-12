-- This module draws a frame around the currently focused window
local frameFocusCanvas = nil

local function updateFocusFrame(_window, _app_name, _event)
  frameFocusCanvas:frame(hs.window.frontmostWindow():frame())
end

local element = {
  type = "rectangle",
  action = "stroke",
  strokeColor = { red = 0.3, green = 1.0 },
  strokeWidth = 8,
  roundedRectRadii = { xRadius = 10.0, yRadius = 10.0 }
}

frameFocusCanvas = hs.canvas.new(hs.window.frontmostWindow():frame())
frameFocusCanvas:assignElement(element, 1)
frameFocusCanvas:show()

frameFocusFilter = hs.window.filter.new(false)
frameFocusFilter:setDefaultFilter()
frameFocusFilter:subscribe(hs.window.filter.windowFocused, updateFocusFrame)
frameFocusFilter:subscribe(hs.window.filter.windowMoved, updateFocusFrame)
