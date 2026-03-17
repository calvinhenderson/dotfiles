-- {{{ Init

require("hs.ipc")

-- Disable window animation
hs.window.animationDuration = 0

-- }}}
-- {{{ SpoonInstall

assert(
	hs.loadSpoon("SpoonInstall"),
	"missing spoon: SpoonInstall (https://github.com/Hammerspoon/Spoons/raw/refs/heads/master/Spoons/SpoonInstall.spoon.zip)"
)

-- {{{ Repos

spoon.SpoonInstall.repos.PaperWM = {
	url = "https://github.com/mogenson/PaperWM.spoon",
	desc = "PaperWM.spoon repository",
	branch = "release",
}

-- }}}
-- {{{ EmmyLua

if not hs.loadSpoon("EmmyLua") then
	spoon.SpoonInstall:updateRepo()
	spoon.SpoonInstall:installSpoonFromZipURL(
		"https://github.com/Hammerspoon/Spoons/raw/refs/heads/master/Spoons/EmmyLua.spoon.zip"
	)
	assert(hs.loadSpoon("EmmyLua"), "failed to load EmmyLua")
end

-- }}}
-- {{{ PaperWM

if not hs.loadSpoon("PaperWM") then
	spoon.SpoonInstall:updateRepo()
	spoon.SpoonInstall:installSpoonFromRepo("PaperWM", "PaperWM")
	assert(hs.loadSpoon("PaperWM"), "failed to load PaperWM")
end

-- }}}
-- {{{ Personal Spoons

local PERSONAL_SPOONS = {
	{ name = "Vi" },
	{ name = "ScrollButton" },
	{ name = "Application" },
	{ name = "System" },
	{ name = "CommandPalette" },
}

for _, v in ipairs(PERSONAL_SPOONS) do
	if not v.disabled or not v.name then
		if not hs.loadSpoon(v.name) then
			print("Installing spoon ", v.name)
			local url = ("https://github.com/calvinhenderson/hammerspoon/releases/download/%s/%s.spoon.zip"):format(
				v.release or "latest",
				v.name
			)
			spoon.SpoonInstall:installSpoonFromZipURL(url)
			hs.loadSpoon(v.name)
			assert(spoon[v.name], ("failed to install spoon %s (%s"):format(v.name, url))
		end
	end
end

-- }}}
-- {{ Load configuration

require("config")

-- }}}
-- {{{ Apply local overrides

local _, err = pcall(function()
	require("local-config")
end)
if err and not err:find("module '.*' not found") then
	print("Error loading local config: " .. err)
end

-- }}}
-- vim:foldmethod=marker
