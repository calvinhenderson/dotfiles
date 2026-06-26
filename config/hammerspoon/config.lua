-- {{{ Mods
local Vi = spoon.Vi
local ScrollButton = spoon.ScrollButton
local Application = spoon.Application
local Apps = spoon.Application.Apps
local System = spoon.System
local PaperWM = spoon.PaperWM
local paper = spoon.PaperWM.actions.actions()

-- }}}
-- {{{ Setup

ScrollButton:setup({ button = 1, scroll_direction = 1, unit = "pixel", x_scale = -2, y_scale = 3 })

PaperWM.window_ratios = {
	0.20,
	0.30,
	0.40,
	0.50,
	0.60,
	0.70,
	0.80,
	1.00,
}
PaperWM.window_gap = 0

hs.application.enableSpotlightForNameSearches(true)

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

local expose = hs.expose.new(nil, {
	textSize = 60,
	backgroundColor = { 0.03, 0.03, 0.03, 0.5 },
	thumbnailAlpha = 0.5,
	closeModeModifier = "cmd",
	closeModeBackgroundColor = { 0.8, 0.1, 0.1, 0.5 },
	minimizeModeModifier = "shift",
	minimizeModeBackgroundColor = { 0.1, 0.3, 0.8, 0.5 },
	onlyActiveApplication = false,
	includeOtherSpaces = true,
	includeNonVisible = false,
	otherSpacesStripPosition = "top",
	otherSpacesStripWidth = 0,
	nonVisibleStripWidth = 0,
	maxHintLetters = 1,
	showThumbnails = true,
	fitWindowsMaxIterations = 10,
})

local function prompt_input(prompt, details)
	local btn, val = hs.dialog.textPrompt(prompt, details or "", "", "Ok", "Cancel", false)
	return (btn == "Ok" and #val > 0) and val or nil
end

_G.pomodoro = {}

function _G.pomodoro:start(duration)
	self.chooser = hs.chooser.new(function() end)

	self.duration = string.upper(duration)

	local hours = tonumber(string.match(self.duration, "(%d+)H")) or 0
	local minutes = tonumber(string.match(self.duration, "(%d+)M")) or 0
	local seconds = tonumber(string.match(self.duration, "(%d+)S")) or 0

	if (not hours and not minutes and not seconds) or (hours + minutes + seconds == 0) then
		hs.alert.show("Invalid duration")
		return
	end

	self.remaining = hours * 3600 + minutes * 60 + seconds
	self.timer:start()
	self.menu:setClickCallback(_(self.reset, self))
end

function _G.pomodoro:create_custom()
	local duration = prompt_input("Duration")

	if not duration then
		hs.alert.show("No duration was given")
		return
	end

	self.notes = prompt_input("Notes")
	self:start(duration)
end

function _G.pomodoro:reset()
	self.menu:setMenu({}):setClickCallback(_(self.create_custom, self)):setTitle("⏲️"):returnToMenuBar()

	if self.notification:delivered() then
		self.notification:withdraw()
	end
	self.duration = nil
	self.notes = nil
	self.timer:stop()
	self.canvas:hide()
	self.running = false
end

function _G.pomodoro:tick(_)
	self.remaining = self.remaining - 1

	local duration = ("%02d:%02d"):format(math.floor(self.remaining / 60), math.ceil(self.remaining % 60))

	if self.remaining > 0 then
		self.menu:setTitle(duration)
	elseif self.remaining == 0 then
		local sframe = hs.screen.mainScreen():frame()
		self.canvas:frame(sframe):show()
		self.menu:setTitle("00:00")
		self.notification
			:title(self.duration and self.duration .. " timer ended" or "Timer ended")
			:informativeText(self.notes or "")
			:send()
	elseif self.remaining < 0 then
		self:reset()
	end
end

_G.pomodoro.timer = hs.timer.new(1, _(_G.pomodoro.tick, _G.pomodoro))
_G.pomodoro.menu = hs.menubar.new(true)
_G.pomodoro.canvas = hs.canvas
	.new({ x = "0%", y = "0%", w = "100%", h = "100%" })
	:insertElement({ type = "rectangle", id = "backdrop", fillColor = { red = 0.5, alpha = 0.3 } })
_G.pomodoro.notification = hs.notify.new(nil, {
	title = "",
	subTitle = "",
	informativeText = "",
	alwaysPresent = true,
	withdrawAfter = 90,
})
_G.pomodoro:reset()

-- }}}
-- {{{ Vi Config

Vi:mergeConfig({
	alert_sound = "Sosumi",
	actions_leave_modes = true,
})

-- }}}
-- {{{ Vi Bindings

local CommandPalette = require("command_palette")

Vi:mergeBindings({
	-- {{{ Modes

	{ "i", H("Esc"), _(Vi.enterMode, Vi, "n"), { leave = false, name = "Enter normal mode" } },

	-- }}}
	-- {{{ Hammerspoon

	{ "n", H("r"), _(hs.reload), { name = "Reload config" } },
	{ "n", H("/"), _(hs.toggleConsole), { name = "Open console" } },
	{ "n", "n", _(hs.notify.withdrawAll), { name = "Clear hs notifications" } },

	-- }}}
	-- {{{ Spaces Jump

	{ "i", H("1"), _(System.focusSpace, 1), { name = "Goto Space 1" } },
	{ "i", H("2"), _(System.focusSpace, 2), { name = "Goto Space 2" } },
	{ "i", H("3"), _(System.focusSpace, 3), { name = "Goto Space 3" } },
	{ "i", H("4"), _(System.focusSpace, 4), { name = "Goto Space 4" } },
	{ "i", H("5"), _(System.focusSpace, 5), { name = "Goto Space 5" } },

	-- }}}
	-- {{{ Choosers

	-- Insert mode
	{ "i", H("Space"), _(CommandPalette.show, CommandPalette), { name = "Command palette" } },
	{ "i", H("."), _(System.window_chooser, "space"), { name = "Choose window (active space)" } },
	{ "i", H("`"), _(System.window_chooser, "app"), { name = "Choose window (current application)" } },
	{ "i", H(","), _(expose.show, expose), { name = "Show expose" } },

	-- }}}
	-- {{{ Goto

	-- Labels
	{ "n", "g", nil, { name = "Go" } },

	-- {{{ Password Manager

	{ "n", "gp", focus("com.bitwarden.Desktop"), { name = "Password Manager" } },

	-- }}}
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

	{ "n", "gg", focus("Google Gemini"), { name = "Gemini" } },

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

	-- Starting and stopping
	{ "i", "<D-C-A-w><S-Esc>", _(PaperWM.stop, PaperWM), { name = "Stop PaperWM" } },
	{ "i", "<D-C-A-w><Esc>", _(PaperWM.start, PaperWM), { name = "Start/reload PaperWM" } },

	-- Moving windows
	{ "i", "<D-C-A-!>", _(paper.move_window_1), { name = "Move to Space 1" } },
	{ "i", "<D-C-A-@>", _(paper.move_window_2), { name = "Move to Space 2" } },
	{ "i", "<D-C-A-#>", _(paper.move_window_3), { name = "Move to Space 3" } },
	{ "i", "<D-C-A-$>", _(paper.move_window_4), { name = "Move to Space 4" } },

	-- Focus prev/next
	{ "i", "<D-C-A-[>", _(paper.focus_left), { name = "Focus prev" } },
	{ "i", "<D-C-A-]>", _(paper.focus_right), { name = "Focus next" } },

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

	-- Alignment
	{ "i", "<D-C-A-w>H", _(System.align_window, { x = "left" }), { name = "Move to left" } },
	{ "i", "<D-C-A-w>s", _(System.align_window, { x = "center" }), { name = "Center horizontally" } },
	{ "i", "<D-C-A-w>L", _(System.align_window, { x = "right" }), { name = "Move to right" } },
	{ "i", "<D-C-A-w>K", _(System.align_window, { y = "top" }), { name = "Move to top" } },
	{ "i", "<D-C-A-w>v", _(System.align_window, { y = "center" }), { name = "Center vertically" } },
	{ "i", "<D-C-A-w>J", _(System.align_window, { y = "bottom" }), { name = "Move to bottom" } },

	-- Columns
	{ "i", "<D-C-A-w>i", _(paper.slurp_in), { name = "Slurp in" } },
	{ "i", "<D-C-A-w>o", _(paper.barf_out), { name = "Barf out" } },

	-- }}}
})

-- }}}
-- {{{ Start Spoons

Vi:start()
ScrollButton:start()
PaperWM:start()

-- }}}
-- vim:foldmethod=marker
