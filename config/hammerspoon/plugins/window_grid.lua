-- Configures a popup for grid-based window move/resize

hs.grid.setGrid('6x3')

-- HINTS must contain at least 5 rows.
-- Even if you are only using 3.. -\_(*_*)_/-
hs.grid.HINTS = {
  -- unused
  { 'f1', 'f2', 'f3', 'f4',  'f5',  'f6' },
  { 'f7', 'f8', 'f9', 'f10', 'f11', 'f12' },

  -- ISRT-based layout
  { 'c',  'l',  'm',  'f',   'u',   ',' },
  { 's',  'r',  't',  'n',   'e',   'a' },
  { 'v',  'w',  'd',  'h',   '/',   '.' },
}

hs.grid.setMargins({ 0, 0 })

require("plugins.leader_key"):bind({}, "g", hs.grid.show)
