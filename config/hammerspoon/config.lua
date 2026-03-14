-- {{{ Mods
local Vi = spoon.Vi
local ScrollButton = spoon.ScrollButton
local Application = spoon.Application
local Apps = spoon.Application.Apps
local System = spoon.System
local PaperWM = spoon.PaperWM
local paper = spoon.PaperWM.actions.actions()

-- }}}
-- {{{ Helpers

local _ = Vi._
local H = _(string.format, "<D-C-A-%s>")

local function send_keys(mods, key, app)
	hs.eventtap.keyStroke(mods, key, nil, app == nil and hs.application.frontmostApplication() or app)
end

local function focus(matchtexts, launcher)
	if type(launcher) == "string" or not launcher then
		launcher = _(hs.application.open, launcher or matchtexts)
	end
	return _(Application.focus_or_launch, matchtexts, launcher)
end

-- }}}
-- {{{ Vi Config

Vi:mergeConfig({
	alert_sound = "Sosumi",
	actions_leave_modes = true,
})

-- }}}
-- {{{ Vi Bindings

Vi:mergeBindings({
	-- {{{ Modes

	{ "i", H("Esc"), _(Vi.enterMode, Vi, "n"), { leave = false, name = "Leave insert mode" } },

	-- }}}
	-- {{{ Hammerspoon

	{ "n", H("r"), _(hs.reload), { name = "Reload config" } },
	{ "n", H("/"), _(hs.toggleConsole), { name = "Open console" } },

	-- }}}
	-- {{{ Spaces Jump

	{ "i", H("1"), _(System.focusSpace, 1), { name = "Goto Space 1" } },
	{ "i", H("2"), _(System.focusSpace, 2), { name = "Goto Space 2" } },
	{ "i", H("3"), _(System.focusSpace, 3), { name = "Goto Space 3" } },
	{ "i", H("4"), _(System.focusSpace, 4), { name = "Goto Space 4" } },
	{ "i", H("5"), _(System.focusSpace, 5), { name = "Goto Space 5" } },

	-- }}}
	-- {{{ Goto

	-- Labels
	{ "n", "g", nil, { name = "Go" } },

	-- {{{ Google Chrome

	-- Labels
	{ "n", "gc", nil, { name = "Chrome" } },

	-- Focus or Launch
	{ "n", "gc1", focus({ ".+Default%)$" }, _(Apps.Chrome.launch_profile, "Default")), { name = "Default" } },
	{ "n", "gc2", focus({ ".+Schools%)$" }, _(Apps.Chrome.launch_profile, "Profile 5")), { name = "Schools" } },
	{ "n", "gc3", focus({ ".+Students%)$" }, _(Apps.Chrome.launch_profile, "Profile 4")), { name = "Students" } },
	{ "n", "gc4", focus({ ".+Developer$" }, _(Apps.Chrome.launch_profile, "Profile 7")), { name = "Developer" } },

	-- New Windows
	{ "n", "gc!", _(Apps.Chrome.launch_profile, "Default"), { name = "New Default" } },
	{ "n", "gc@", _(Apps.Chrome.launch_profile, "Profile 5"), { name = "New Schools" } },
	{ "n", "gc#", _(Apps.Chrome.launch_profile, "Profile 4"), { name = "New Students" } },
	{ "n", "gc$", _(Apps.Chrome.launch_profile, "Profile 7"), { name = "New Developer" } },

	-- Google Apps PWAs
	{ "n", "gcc", focus("Google Chat"), { name = "Messages" } },
	{ "n", "gc-", focus("Google Calendar"), { name = "Calendar" } },
	{ "n", "gcm", focus("Gmail"), { name = "Gmail" } },
	{ "n", "gct", focus("Google Tasks"), { name = "Tasks" } },

	-- }}}
	-- {{{ Alacritty

	{ "n", "gs", focus({ Apps.Alacritty.bundleid }, _(Apps.Alacritty.new_window)), { name = "Alacritty" } },
	{ "n", "gS", _(Apps.Alacritty.new_window), { name = "New Alacritty" } },

	-- }}}
	-- {{{ Gemini

	{ "n", "gg", focus("Chat"), { name = "Gemini" } },

	-- }}}
	-- }}}
	-- {{{ Cycle

	-- Labels
	{ "n", "[", nil, { name = "Previous" } },
	{ "n", "]", nil, { name = "Next" } },

	-- {{{ Space

	{ "n", "[s", _(send_keys, { "fn", "ctrl" }, "left", false), { leave = false, name = "Space" } },
	{ "n", "]s", _(send_keys, { "fn", "ctrl" }, "right", false), { leave = false, name = "Space" } },

	-- }}}
	-- {{{ Application Tabs

	{ "n", "[t", _(Application.prev_tab), { leave = false, name = "Tab" } },
	{ "n", "]t", _(Application.next_tab), { leave = false, name = "Tab" } },

	-- }}}
	-- }}}
	-- {{{ PaperWM

	-- Moving windows
	{ "i", "<D-C-A-!>", _(paper.move_window_1), { name = "Move to Space 1" } },
	{ "i", "<D-C-A-@>", _(paper.move_window_2), { name = "Move to Space 2" } },
	{ "i", "<D-C-A-#>", _(paper.move_window_3), { name = "Move to Space 3" } },
	{ "i", "<D-C-A-$>", _(paper.move_window_4), { name = "Move to Space 4" } },

	-- Focus prev/next
	{ "i", "<D-C-A-[>", _(paper.focus_prev), { name = "Focus prev" } },
	{ "i", "<D-C-A-]>", _(paper.focus_next), { name = "Focus next" } },

	-- Swap prev/next
	{ "i", "<D-C-A-{>", _(paper.swap_left), { name = "Swap prev" } },
	{ "i", "<D-C-A-}>", _(paper.swap_right), { name = "Swap next" } },

	-- Focus HJKL
	{ "i", "<D-C-A-h>", _(paper.focus_left), { name = "Focus left" } },
	{ "i", "<D-C-A-j>", _(paper.focus_down), { name = "Focus down" } },
	{ "i", "<D-C-A-k>", _(paper.focus_up), { name = "Focus up" } },
	{ "i", "<D-C-A-l>", _(paper.focus_right), { name = "Focus right" } },
	{ "i", "<D-C-A-Left>", _(paper.focus_left), { name = "Focus left" } },
	{ "i", "<D-C-A-Down>", _(paper.focus_down), { name = "Focus down" } },
	{ "i", "<D-C-A-Up>", _(paper.focus_up), { name = "Focus up" } },
	{ "i", "<D-C-A-Right>", _(paper.focus_right), { name = "Focus right" } },

	-- Swap HJKL
	{ "i", "<D-C-A-H>", _(paper.swap_left), { name = "Swap left" } },
	{ "i", "<D-C-A-J>", _(paper.swap_down), { name = "Swap down" } },
	{ "i", "<D-C-A-K>", _(paper.swap_up), { name = "Swap up" } },
	{ "i", "<D-C-A-L>", _(paper.swap_right), { name = "Swap right" } },
	{ "i", "<D-C-A-S-Left>", _(paper.swap_left), { name = "Swap left" } },
	{ "i", "<D-C-A-S-Down>", _(paper.swap_down), { name = "Swap down" } },
	{ "i", "<D-C-A-S-Up>", _(paper.swap_up), { name = "Swap up" } },
	{ "i", "<D-C-A-S-Right>", _(paper.swap_right), { name = "Swap right" } },

	-- Layout
	{ "i", "<D-C-A-w>|", _(paper.full_width), { name = "Max out width" } },
	{ "i", "<D-C-A-w>=", _(paper.split_screen), { name = "Split screen" } },
	{ "i", "<D-C-A-w><", _(paper.reverse_cycle_width), { name = "Decrease width" } },
	{ "i", "<D-C-A-w>>", _(paper.cycle_width), { name = "Increase width" } },
	{ "i", "<D-C-A-w>-", _(paper.reverse_cycle_height), { name = "Decrease height" } },
	{ "i", "<D-C-A-w>+", _(paper.cycle_height), { name = "Increase height" } },
	{ "i", "<D-C-A-w><Space>", _(paper.toggle_floating), { name = "Toggle floating" } },
	{ "i", "<D-C-A-w>f", _(paper.focus_floating), { name = "Focus floating" } },

	-- Columns
	{ "i", "<D-C-A-w>i", _(paper.slurp_in), { name = "Slurp in" } },
	{ "i", "<D-C-A-w>o", _(paper.barf_out), { name = "Barf out" } },

	-- }}}
})

-- }}}
-- {{{ Spoons

ScrollButton:setup({ button = 1, scroll_direction = 1, unit = "pixel", x_scale = -2, y_scale = 3 })

PaperWM.window_ratios = { 1 / 5, 1 / 4, 1 / 3, 1 / 2, 3 / 5, 3 / 4, 2 / 3, 1 }
PaperWM.window_gap = 0

Vi:start()
ScrollButton:start()
PaperWM:start()

-- }}}
-- vim:set foldmethod=marker
