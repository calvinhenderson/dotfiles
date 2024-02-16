local utils = {}

---Returns the absolute directory of the caller's script
---@param  n_callers number | nil The number of calling functions to skip
---@return string          The absolute directory of the containing script
utils.script_dir = function(n_callers)
  local stack_depth = 2 + (n_callers or 0)
  return vim.fs.dirname(debug.getinfo(stack_depth, "S").source:sub(2))
end


---Checks wether a table contains the cooresponding value
---@param  table   table The table to check
---@param  value   any   The value to search for
---@return boolean       `true` if found, `false` otherwise
utils.contains = function(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end

  return false
end

---Requires all neighboring scripts
---@param  opts  table | nil Accepts a single table `exclude` where each element is a module path.
---@return table       A table including the key-value pairs of required modules
utils.require_all = function(opts)
  local requires = {}
  local dir = utils.script_dir(1)
  local module_prefix = opts.prefix or ''
  local module_path = module_prefix .. vim.fs.basename(dir)

  if opts == nil then
    opts = {}
  end

  local excludes = opts.exclude or {}

  for f, t in vim.fs.dir(dir, { depth = 1 }) do
    local include = true
    local basename = vim.fs.basename(f)

    if basename:sub(-4) == ".lua" then
      basename = basename:sub(1, -5)
    end

    -- Only include valid scripts that are not the base module init and are not explicitly excluded
    if (t == "file" and not f:sub(-4) ~= ".lua")
        or f == "init.lua"
        or utils.contains(excludes, module_path)
        or (t == "directory" and not vim.loop.fs_stat(dir .. "/" .. f .. "/init.lua")) then
      include = false
    end

    if include then
      requires[basename] = require(module_path .. '.' .. basename)
    end
  end

  return requires
end

return utils
