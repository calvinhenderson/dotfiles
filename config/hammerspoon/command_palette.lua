local System = spoon.System
local Application = spoon.Application
local Apps = spoon.Application.Apps
local _ = spoon.Vi._

hs.application.enableSpotlightForNameSearches(true)

_G.caffeinate_icon = hs.menubar.new(true):removeFromMenuBar()
_G.caffeinate_task = nil

local function toggle_caffeinate()
	if not _G.caffeinate_task then
		_G.caffeinate_task = hs.task
			.new("/usr/bin/caffeinate", function(_, _, _)
				_G.caffeinate_task = nil
				_G.caffeinate_icon:removeFromMenuBar()
			end, { "-dsiu" })
			:start()
		_G.caffeinate_icon:returnToMenuBar():setTitle("☕️")
	else
		_G.caffeinate_task:terminate()
		_G.caffeinate_task = nil
		_G.caffeinate_icon:removeFromMenuBar()
	end
end

spoon.CommandPalette:defaultChoices({

	{
		text = "Bitwarden",
		subText = "Bitwarden",
		image = System.application_icon("Bitwarden"),
		application = "Bitwarden",
	},

	{
		text = "Choose audio device",
		subText = "System Settings",
		image = System.application_icon("System Settings"),
		action = System.audio_output_chooser,
	},

	{
		text = "Google Calendar",
		subText = "Google Chrome",
		image = System.application_icon("Google Calendar"),
		application = "Google Calendar",
	},

	{
		text = "Google Tasks",
		subText = "Google Chrome",
		image = System.application_icon("Google Tasks"),
		application = "Google Tasks",
	},

	{
		text = "Google Chat",
		subText = "Google Chrome",
		image = System.application_icon("Google Chat"),
		application = "Google Chat",
	},

	{
		text = "Gmail",
		subText = "Google Chrome",
		image = System.application_icon("Gmail"),
		application = "Gmail",
	},

	{
		text = "Default Profile",
		subText = "Google Chrome",
		image = System.application_icon("Google Chrome"),
		action = function()
			Apps.Chrome.launch_profile("Default")
		end,
	},

	{
		text = "Staff Admin Profile",
		subText = "Google Chrome",
		image = System.application_icon("Google Chrome"),
		action = function()
			Apps.Chrome.launch_profile("Profile 5")
		end,
	},

	{
		text = "Student Admin Profile",
		subText = "Google Chrome",
		image = System.application_icon("Google Chrome"),
		action = function()
			Apps.Chrome.launch_profile("Profile 4")
		end,
	},

	{
		text = "Developer Profile",
		subText = "Google Chrome",
		image = System.application_icon("Google Chrome"),
		action = function()
			Apps.Chrome.launch_profile("Profile 7")
		end,
	},

	{
		text = "Desktop folder",
		subText = "Finder",
		image = hs.image.imageFromName("NSFolder"),
		command = "open ~/Desktop",
	},

	{
		text = "Downloads folder",
		subText = "Finder",
		image = hs.image.imageFromName("NSFolder"),
		command = "open ~/Downloads",
	},

	{
		text = "Gemini",
		subText = "Google Gemini",
		image = System.application_icon("Google Gemini"),
		application = "Google Gemini",
	},

	{
		text = "Generate password",
		subText = "Command",
		image = System.application_icon("Terminal"),
		action = function()
			local res = hs.execute("gen-pw", true)
			hs.pasteboard.setContents(res)
			hs.alert("Generated password")
		end,
	},

	{
		text = "Format JSON from clipboard",
		subText = "Command",
		image = System.application_icon("Terminal"),
		command = "pbpaste | jq | pbcopy",
	},

	{
		text = "Home folder",
		subText = "Finder",
		image = hs.image.imageFromName("NSFolder"),
		command = "open ~/",
	},

	{
		text = "New terminal window",
		subText = "Alacritty",
		image = System.application_icon("Alacritty"),
		action = Apps.Alacritty.new_window,
	},

	{
		text = "Obsidian",
		subText = "Obsidian",
		image = System.application_icon("Obsidian"),
		command = "open obsidian://",
	},

	{
		text = "Toggle dark mode",
		subText = "System Settings",
		image = System.application_icon("System Settings"),
		applescript = [[
        tell application "System Events" to tell appearance preferences to set dark mode to not dark mode
      ]],
	},

	{
		text = "Toggle caffeinate",
		subText = "System Settings",
		image = System.application_icon("System Settings"),
		action = _(toggle_caffeinate),
	},

	{
		text = "Create pomodoro timer",
		subText = "Hammerspoon",
		image = System.application_icon("Hammerspoon"),
		action = _(_G.pomodoro.create_custom, _G.pomodoro),
	},

	{
		text = "Clear notifications",
		subText = "Hammerspoon",
		image = System.application_icon("Hammerspoon"),
		action = _(hs.notify.withdrawAll),
	},

	{
		text = "Google Apps",
		subText = "Google",
		image = System.application_icon("Google Chrome"),
		action = function()
			hs.application.open("Google Calendar")
			hs.application.open("Google Tasks")
			hs.application.open("Gmail")
			hs.application.open("Google Chat")
		end,
	},
})

return spoon.CommandPalette
