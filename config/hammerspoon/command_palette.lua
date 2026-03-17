local System = spoon.System
local Application = spoon.Application
local Apps = spoon.Application.Apps

hs.application.enableSpotlightForNameSearches(true)

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
})

return spoon.CommandPalette
