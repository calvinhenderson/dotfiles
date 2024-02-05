-- This plugin automatically reloads the config when a file changes.

function reloadConfig(files)
  local doReload = false
  for _, file in pairs(files) do
    if file:sub(-4) == ".lua" then
      doReload = true
    end
  end
  if doReload then
    hs.reload()
  end
end

config_watcher = hs.pathwatcher.new(require("../util.paths").config_root, reloadConfig):start()
hs.notify.show("Hammerspoon", "Reading config", "")
