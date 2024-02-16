-- Theme toggle
vim.g.autodark = 0
vim.o.background = 'dark'
vim.cmd.colorscheme('gruvbox')

local timer = vim.loop.new_timer()
if timer ~= nil then
  timer:start(0, 2000, vim.schedule_wrap(function()
    -- Early return if disabled
    if vim.g.autodark ~= 1 then
      return
    end

    local dark_mode = true
    if vim.fn.has('macunix') ~= 0 then
      local system_theme = vim.fn.system { 'defaults', 'read', '-g', 'AppleInterfaceStyle' }
      if not string.find(system_theme, "Dark", 0) then
        dark_mode = false
      end
    end
    vim.o.background = dark_mode and 'dark' or 'light'
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
