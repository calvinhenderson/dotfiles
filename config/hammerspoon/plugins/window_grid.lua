-- Configures a popup for grid-based window move/resize

hs.grid.setGrid('8x4')


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

hs.grid.setMargins({ 0, 0 })

require("plugins.leader_key"):bind({}, "g", hs.grid.show)
