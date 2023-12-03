local elixirls = {}

-- Download base URL
elixirls.releases_url = 'https://api.github.com/repos/elixir-lsp/elixir-ls/releases'

-- Splits a string at every occurence of separator.
string.split = function(s, separator)
  if separator == nil then
    separator = "%s"
  end
  local t = {}
  for match in string.gmatch(s, "([^" .. separator .. "]+)") do
    table.insert(t, match)
  end
  return t
end

-- Gets latest elixir-ls release information
-- Returns file name, file url
local function get_latest_release()
  local resp = vim.fn.system { 'curl', '-s', elixirls.releases_url }
  local release_url = vim.json.decode(resp)[1].assets[1].browser_download_url
  local parts = string.split(release_url, '/')
  return parts[#parts], release_url
end

-- Configure the local or global path for the language server
local function setup_path()
  local path = vim.fn.stdpath 'data' .. '/elixir-ls'

  vim.fn.mkdir(path, "p")

  return path
end

-- Downloads a file to the specified destination
local function download_file(url, dest)
  vim.fn.system { 'curl', '-o', dest, '-sfL', url }
end

-- Unzips a file to the specified destination
local function unzip_file(file, dest)
  vim.fn.system { 'unzip', file, '-d', dest }
end

-- Gets the system temp dir
local function temp_dir()
  local tmp = vim.fn.environ()['TMPDIR']
  return tmp ~= '' and tmp or '/tmp'
end

-- Installs ElixirLS if it doesn't already exist
function elixirls.install()
  local path = setup_path()

  -- Check for an existing language server
  if vim.loop.fs_stat(path .. '/language_server.sh') then
    return path
  end

  print('[elixir-ls] installing')

  local file, url = get_latest_release()
  local zip = temp_dir() .. '/' .. file

  -- Download the language server only if it doesn't already exist
  if not vim.loop.fs_stat(zip) then
    download_file(url, zip)
  end

  -- Install the language server to the configured path
  unzip_file(zip, path)
  vim.fn.system { 'chmod', '+x', path .. '/language_server.sh' }

  -- Verify the installation
  if vim.loop.fs_stat(path .. '/language_server.sh') then
    print('[elixir-ls] installed')
  else
    print('[elixir-ls] installation failed.')
  end

  return path
end

return elixirls
