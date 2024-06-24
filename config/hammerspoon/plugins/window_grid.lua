-- Configures a popup for grid-based window move/resize
local leader = require("plugins.leader_key")

hs.grid.setMargins({ 0, 0 })

-- hs.inspect(hs.screen.allScreens())

-- HINTS must contain at least 5 rows.
-- Even if you are only using 4.. -\_(*_*)_/-
local hints = {
  -- ISRT-based layout
  { 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9' },
  { '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9', },
  { 'c',  'l',  'm',  'k',  'z',  'f',  'u',  ',', },
  { 's',  'r',  't',  'g',  'p',  'n',  'e',  'a', },
  { 'v',  'w',  'd',  'j',  'b',  'h',  '/',  '.', },
}

local function setGridForScreen(screen)
  local frame = screen:frame()
  if frame.w > frame.h then
    hs.grid.setGrid('8x5', screen)
  else
    hs.grid.setGrid('4x8', screen)
  end
end

local function fitWindows()
  hs.grid.HINTS = hints
  for _, screen in pairs(hs.screen.allScreens()) do
    setGridForScreen(screen)
  end

  for _, window in pairs(hs.window.visibleWindows()) do
    if window:subrole() == "AXStandardWindow" then
      hs.grid.snap(window)
    end
  end
end

local function showGrid()
  setGridForScreen(hs.window.focusedWindow():screen())
  hs.grid.show()
end

leader:bind({}, "g", showGrid)
leader:bind({}, "s", fitWindows)

fitWindows()
