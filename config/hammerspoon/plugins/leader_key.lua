-- [[
--
-- Adapted from this gist: https://gist.github.com/casouri/06e02230dbfd6ab68fd1798ddb025148
--
-- ]]


-- key to break out of every layer and back to normal
escapeKey = { keyNone, 'escape' }

-- max length of helper measured in character
recursiveBindHelperMaxLineLengthInChar = 80

-- format of helper, the helper is just a hs.alert
recursiveBindHelperFormat = {
  atScreenEdge = 2,
  strokeColor = { white = 0, alpha = 2 },
  textFont = 'SF Mono'
}

-- whether to show helper
showBindHelper = true

-- used by next model to close previous helper
local previousHelperID = nil

-- generate a string representation of a key spec
-- {{'shift', 'command'}, 'a} -> 'shift+command+a'
local function createKeyName(key)
  -- key is in the form {{modifers}, key, (optional) name}
  -- create proper key name for helper
  if #key[1] == 1 and key[1][1] == 'shift' then
    -- shift + key map to Uppercase key
    -- shift + d --> D
    return keyboardUpper(key[2])
  else
    -- append each modifiers together
    local keyName = ''
    if #key[1] >= 1 then
      for count = 1, #key[1] do
        if count == 1 then
          keyName = key[1][count]
        else
          keyName = keyName .. ' + ' .. key[1][count]
        end
      end
    end
    -- finally append key, e.g. 'f', after modifers
    return keyName .. key[2]
  end
end

-- show helper of available keys of current layer
local function showHelper(keyFuncNameTable)
  -- keyFuncNameTable is a table that key is key name and value is description
  local helper = ''
  local separator = '' -- first loop doesn't need to add a separator, because it is in the very front.
  local lastLine = ''
  for keyName, funcName in pairs(keyFuncNameTable) do
    -- only measure the length of current line
    lastLine = string.match(helper, '\n.-$')
    if lastLine and string.len(lastLine) > recursiveBindHelperMaxLineLengthInChar then
      separator = '\n'
    elseif not lastLine then
      separator = '\n'
    end
    helper = helper .. separator .. keyName .. ' → ' .. funcName
    separator = '   '
  end
  helper = string.match(helper, '[^\n].+$')
  -- bottom of screen, lasts for 3 sec, no border
  previousHelperID = hs.alert.show(helper, recursiveBindHelperFormat, true)
end


-- Spec of keymap:
-- Every key is of format {{modifers}, key, (optional) description}
-- The first two element is what you usually pass into a hs.hotkey.bind() function.
--
-- Each value of key can be in two form:
-- 1. A function. Then pressing the key invokes the function
-- 2. A table. Then pressing the key bring to another layer of keybindings.
--    And the table have the same format of top table: keys to keys, value to table or function


-- the actual binding function
function recursiveBind(keymap)
  if type(keymap) == 'function' then
    -- in this case "keymap" is actually a function
    return keymap
  end
  local modal = hs.hotkey.modal.new()
  local keyFuncNameTable = {}
  for key, map in pairs(keymap) do
    local func = recursiveBind(map)
    -- key[1] is modifiers, i.e. {'shift'}, key[2] is key, i.e. 'f'
    modal:bind(key[1], key[2], function()
      modal:exit()
      hs.alert.closeSpecific(previousHelperID)
      func()
    end)
    modal:bind(escapeKey[1], escapeKey[2], function()
      modal:exit()
      hs.alert.closeSpecific(previousHelperID)
    end)
    if #key >= 3 then
      keyFuncNameTable[createKeyName(key)] = key[3]
    end
  end
  return function()
    modal:enter()
    hs.timer.doAfter(3, function() modal:exit() end)
    if showHelper then
      showHelper(keyFuncNameTable)
    end
  end
end

-- this function is used by helper to display
-- appropriate 'shift + key' bindings
-- it turns a lower key to the corresponding
-- upper key on keyboard
function keyboardUpper(key)
  local upperTable = {
    a = 'A',
    b = 'B',
    c = 'C',
    d = 'D',
    e = 'E',
    f = 'F',
    g = 'G',
    h = 'H',
    i = 'I',
    j = 'J',
    k = 'K',
    l = 'L',
    m = 'M',
    n = 'N',
    o = 'O',
    p = 'P',
    q = 'Q',
    r = 'R',
    s = 'S',
    t = 'T',
    u = 'U',
    v = 'V',
    w = 'W',
    x = 'X',
    y = 'Y',
    z = 'Z',
    ['`'] = '~',
    ['1'] = '!',
    ['2'] = '@',
    ['3'] = '#',
    ['4'] = '$',
    ['5'] = '%',
    ['6'] = '^',
    ['7'] = '&',
    ['8'] = '*',
    ['9'] = '(',
    ['0'] = ')',
    ['-'] = '_',
    ['='] = '+',
    ['['] = '}',
    [']'] = '}',
    ['\\'] = '|',
    [';'] = ':',
    ['\''] = '"',
    [','] = '<',
    ['.'] = '>',
    ['/'] = '?'
  }
  uppperKey = upperTable[key]
  if uppperKey then
    return uppperKey
  else
    return key
  end
end

function singleKey(key, name)
  local mod = {}
  if key == keyboardUpper(key) then
    mod = { 'shift' }
    key = string.lower(key)
  end

  if name then
    return { mod, key, name }
  else
    return { mod, key, 'no name' }
  end
end

-- Spec of keymap:
-- Every key is of format {{modifers}, key, (optional) description}
-- The first two element is what you usually pass into a hs.hotkey.bind() function.
--
-- Each value of key can be in two form:
-- 1. A function. Then pressing the key invokes the function
-- 2. A table. Then pressing the key bring to another layer of keybindings.
--    And the table have the same format of top table: keys to keys, value to table or function

--[[ and example of configuration
mymapWithName = {
   [singleKey('`', 'run command')] = runCommand,
   [singleKey('f', 'find+')] = {
      [singleKey('D', 'Desktop')] = function() openWithFinder('~/Desktop') end,
      [singleKey('p', 'Project')] = function() openWithFinder('~/p') end,
      [singleKey('d', 'Download')] = function() openWithFinder('~/Downloads') end,
      [singleKey('a', 'Application')] = function() openWithFinder('~/Applications') end,
      [singleKey('h', 'home')] = function() openWithFinder('~') end,
      [singleKey('f', 'hello')] = function() hs.alert.show('hello!') end},
   [singleKey('t', 'toggle+')] = {
      [singleKey('v', 'file visible')] = function() hs.eventtap.keyStroke({'cmd', 'shift'}, '.') end
   },
   [singleKey('h', '←')] = function() moveAndResize('left') moveWindowMode() end,
   [singleKey('j', '↓')] = function() moveAndResize('down') moveWindowMode() end,
   [singleKey('k', '↑')] = function() moveAndResize('up') moveWindowMode() end,
   [singleKey('l', '→')] = function() moveAndResize('right') moveWindowMode() end
}
hs.hotkey.bind(keyMod, 'space', nil, recursiveBind(mymapWithName))
--]]

return recursiveBind
