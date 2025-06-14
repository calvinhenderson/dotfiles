-- Auto-load the plugins directory
-- local plugin_dir = require("config").config_root .. "/plugins"
-- for file in hs.fs.dir(plugin_dir) do
--   if file:sub(-4) == ".lua" then
--     print("Loading plugin " .. file)
--     require("plugins." .. file:sub(0, -5))
--   end
-- end

hs.alert.show("Hammerspoon config loaded")

config_root = os.getenv("HOME") .. "/.config/hammerspoon/"
hyper = { "cmd", "ctrl", "alt" }

-- bind reload at start in case of error later in config
hs.hotkey.bind(hyper, "r", hs.reload)
hs.hotkey.bind(hyper, "/", hs.toggleConsole)

-- uncomment this to generate lua definitions
-- hs.loadSpoon("EmmyLua")

function inspect(value)
  print(hs.inspect(value))
end

-- install cli
arch = io.popen('uname -p', 'r'):read('*l')
path = arch == 'arm' and '/opt/homebrew' or nil
hs.ipc.cliInstall(path)
hs.ipc.cliSaveHistory(true)

mouseScroll = require("plugins.mouse_scroll")
leader = require("plugins.leader_key")

fennel = require("fennel")
table.insert(package.loaders or package.searchers, fennel.searcher)
fennel.dofile(config_root .. "init.fnl") -- exports into global namespace
