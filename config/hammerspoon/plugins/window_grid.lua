-- Configures a popup for grid-based window move/resize
local leader = require("plugins.leader_key")

hs.grid.setGrid('8x4')
hs.grid.setMargins({ 5, 5 })

-- HINTS must contain at least 5 rows.
-- Even if you are only using 3.. -\_(*_*)_/-
hs.grid.HINTS = {
  -- unused
  { 'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8' },

  -- ISRT-based layout
  { 'c',  'l',  'm',  'k',  'f',  'z',  'u',  ',' },
  { '2',  '3',  '4',  '5',  '6',  '7',  '8',  '9' },
  { 's',  'r',  't',  'g',  'n',  'p',  'e',  'a' },
  { 'v',  'w',  'd',  'j',  'b',  'h',  '/',  '.' },
}

local function fitWindows()
  for _, window in pairs(hs.window.visibleWindows()) do
    if window:subrole() == "AXWindow" then
      hs.grid.snap(window)
    end
  end
end

leader:bind({}, "g", hs.grid.show)
leader:bind({}, "s", fitWindows)

fitWindows()
