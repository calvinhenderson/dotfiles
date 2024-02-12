local leader = require("../config").leader

-- The modal for executing leader key combos
leaderMode = hs.hotkey.modal.new(leader.mods, leader.key, nil)

-- Override the default bind function
leaderMode.bind = function(mode, mods, key, pressed_fn)
  hs.hotkey.modal.bind(mode, mods, key, nil, function()
    pressed_fn()
    leaderMode:exit()
  end, nil)
end

-- Create a canvas with a circle indicator
leaderMode.canvas = hs.canvas.new({ x = 0, y = 0, w = 60, h = 60 })
leaderMode.canvas:insertElement({ type = "circle", id = "leader-indicator", fillColor = { green = 1 } })

leaderMode.entered = function()
  leaderMode.canvas:show(0.25)

  -- Get the active screen position and size
  local frame = leaderMode.canvas:frame()
  local offset = hs.screen.mainScreen():frame().topleft

  -- Place the indicator in the bottom right corner
  leaderMode.canvas:frame({ x = offset.x + frame.w, y = offset.y + frame.h, w = frame.w, h = frame.h })
end

leaderMode.exited = function()
  leaderMode.canvas:hide(0.25)
end

-- Leader key twice forwards the combo
leaderMode:bind(leader.mods, leader.key, function()
  hs.eventtap.keyStroke(leader.mods, leader.key)
end)
-- Escape exits leader mode
leaderMode:bind({}, "escape", function() leaderMode:exit() end)

return leaderMode
