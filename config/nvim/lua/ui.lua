-- Theme toggle
vim.g.autodark = 0
vim.o.background = 'dark'

-- Set the colorscheme to gruvbox
vim.cmd.colorscheme('gruvbox')

-- Update the rainbow-delimiter colors to gruvbox
local highlight = {
  "GruvboxRed",
  "GruvboxYellow",
  "GruvboxBlue",
  "GruvboxOrange",
  "GruvboxGreen",
  "GruvboxPurple",
  "GruvboxAqua"
}

require("ibl").setup { scope = { highlight = highlight } }
vim.g.rainbow_delimiters = { highlight = highlight }

-- Poll the system theme
local timer = vim.loop.new_timer()
if timer ~= nil then
  timer:start(0, 2000, vim.schedule_wrap(function()
    -- Early return if disabled
    if vim.g.autodark ~= 1 then
      return
    end

    local system_theme = ''

    if vim.fn.executable('defaults') == 1 then
      system_theme = vim.fn.system { 'defaults', 'read', '-g', 'AppleInterfaceStyle' }
    elseif vim.fn.executable('gsettings') == 1 then
      system_theme = vim.fn.system { 'gsettings', 'get', 'org.gnome.desktop.interface', 'colorscheme' }
    end

    -- Check for light specifically so dark is default
    local background
    if not string.find(string.lower(system_theme), "dark", 0) then
      background = 'light'
    else
      background = 'dark'
    end

    vim.o.background = background
  end))
end

-- Highlight selection on yank
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- vim: ts=2 sts=2 sw=2 et
