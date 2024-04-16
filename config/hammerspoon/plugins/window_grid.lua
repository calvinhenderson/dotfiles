-- Configures a popup for grid-based window move/resize
local leader = require("plugins.leader_key")

hs.grid.setGrid('4x8')
hs.grid.setMargins({ 5, 5 })

-- HINTS must contain at least 5 rows.
-- Even if you are only using 3.. -\_(*_*)_/-
hs.grid.HINTS = {
  -- ISRT-based layout
  { '2',  '3',  '4',  '5', },
  { 'c',  'l',  'm',  'k', },
  { 'v',  'w',  'd',  'j', },
  { 'z',  'f',  'u',  ',', },
  { 'b',  'h',  '/',  '.', },

  -- unused
  { 'f1', 'f2', 'f3', 'f4', },
  { 'f5', 'f6', 'f7', 'f8' },

  { 's',  'r',  't',  'g', },
  { '6',  '7',  '8',  '9', },
  { 'p',  'n',  'e',  'a', },
}

local function fitWindows()
  for _, window in pairs(hs.window.visibleWindows()) do
    if window:subrole() == "AXStandardWindow" then
      hs.grid.snap(window)
    end
  end
end

leader:bind({}, "g", hs.grid.show)
leader:bind({}, "s", fitWindows)

fitWindows()
