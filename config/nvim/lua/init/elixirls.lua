local elixirls = {}

-- Download base URL
elixirls.base_url = 'https://github.com/elixir-lsp/elixir-ls/releases/latest/download'
elixirls.file_template = 'elixir-ls-v0.16.0.zip'

-- Configure the local or global path for the language server
local function setup_path()
  local path = vim.fn.stdpath 'data' .. '/elixir-ls'

  vim.fn.mkdir(path, "p")

  return path
end

-- Get the download url for a specific version of the language server
local function get_download_url()
  local url = elixirls.base_url .. '/' .. elixirls.file_template
  return url
end

-- Downloads a file to the specified destination
local function download_file(url, dest)
  vim.fn.system { 'curl', '-o', dest, '-sfL', url }
end

-- Unzips a file to the specified destination
local function unzip_file(file, dest)
  vim.fn.system { 'unzip', file, '-d', dest }
end

-- Installs ElixirLS if it doesn't already exist
function elixirls.install()
  local path = setup_path()

  -- Check for an existing language server
  if vim.loop.fs_stat(path .. '/language_server.sh') then
    -- print('[elixir-ls] using existing lsp at '..path)
    return path
  end

  -- Get the currently running Elixir and Erlang/OTP version
  local zip = '/tmp/elixir-ls.zip'

  -- Download the language server
  if not vim.loop.fs_stat(zip) then
    print('[elixir-ls] downloading..')
    download_file(get_download_url(), zip)
  else
    print('[elixir-ls] skipping download. file exists.')
  end

  -- Install the language server to the configured path
  print('[elixir-ls] installing..')
  unzip_file(zip, path)
  vim.fn.system { 'chmod', '+x', path .. '/language_server.sh' }

  -- Verify the installation
  if vim.loop.fs_stat(path .. '/language_server.sh') then
    print('[elixir-ls] installed to ' .. path)
  else
    print('[elixir-ls] installation failed.')
  end

  if vim.loop.fs_stat(zip) then
    vim.fn.delete(zip)
  end

  return path
end

return elixirls
