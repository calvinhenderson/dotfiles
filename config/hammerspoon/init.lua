-- Auto-load the plugins directory
local plugin_dir = require("config").config_root .. "/plugins"
for file in hs.fs.dir(plugin_dir) do
  if file:sub(-4) == ".lua" then
    print("Loading plugin " .. file)
    require("plugins." .. file:sub(0, -5))
  end
end
