-- This plugin provides a popup window switcher
-- similar to the file switchers in most editors.

-- Stores the currently focused window to ensure it is last in the list
local focused_window = nil

-- Gets the icon for an application from its bundle.
local function getApplicationIcon(application)
  return hs.image.imageFromAppBundle(application:bundleID())
end

-- Chooser callback for selecting a window
local function chooseWindow(choice)
  -- Don't do anything if the user cancels..
  if choice == nil then
    return
  end

  local window = hs.window.get(choice.uuid)
  local spaces = hs.spaces.windowSpaces(window)

  -- This is required when switching to applications
  -- with multiple windows across spaces
  window:becomeMain()
  hs.timer.usleep(1000)

  if #spaces > 0 and hs.spaces.focusedSpace() ~= spaces[1] then
    hs.spaces.gotoSpace(spaces[1])
  end

  -- Finally, focus the selected window
  window:focus()
end

-- Returns the chooser meta for the specified window
local function getWindowChooserMeta(window)
  return {
    text = window:title(),
    subText = window:application():title(),
    uuid = window:id(),
    image = getApplicationIcon(window:application())
  }
end

-- Returns a sorted list of recent windows
local function getWindows()
  -- Configure a window filter for retrieving sorted windows
  local window_filter = hs.window.filter.new(false)
  window_filter:setDefaultFilter()
  window_filter:setCurrentSpace(nil)
  window_filter:setSortOrder(hs.window.filter.sortByFocusedLast)

  local choices = {}
  for _, window in ipairs(window_filter:getWindows()) do
    -- Skip adding the focused window
    if window:id() ~= focused_window:id() then
      choices[#choices + 1] = getWindowChooserMeta(window)
    end
  end

  -- Add the currently focused window to the end
  choices[#choices + 1] = getWindowChooserMeta(focused_window)

  return choices
end

local windowSwitcher = hs.chooser.new(chooseWindow)

if hs.host.interfaceStyle() == 'Dark' then
  windowSwitcher:bgDark(true)
  windowSwitcher:fgColor({ 1, 1, 1 })
  windowSwitcher:subTextColor({ 1, 1, 1 })
end

windowSwitcher:searchSubText(true)
windowSwitcher:choices(getWindows)

require("plugins.leader_key"):bind({}, "w", function()
  -- Reset the query text
  focused_window = hs.window.frontmostWindow()
  windowSwitcher:choices(getWindows)
  windowSwitcher:query("")
  windowSwitcher:show()
end)
