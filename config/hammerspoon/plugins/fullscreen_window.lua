-- Adds a shortcut for toggling the focused window in/out of fullscreen

require("plugins.leader_key"):bind({}, "f", function()
  local window = hs.window.frontmostWindow()
  window:setFullscreen(not window:isFullscreen())
end)
