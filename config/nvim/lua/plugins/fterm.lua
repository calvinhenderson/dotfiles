local fterm = require 'FTerm'
fterm.setup {
  cmd = os.getenv('SHELL') ~= '' and os.getenv('SHELL') or '/bin/bash',
  border = 'single',
  auto_close = true,
  blend = 0,
  dimensions = {
    height = 0.8,
    width = 0.8,
    x = 0.5,
    y = 0.5,
  },
}

vim.keymap.set('n', '<leader>`', require 'FTerm'.toggle, { desc = 'Toggle floating terminal' })

-- vim: ts=2 sts=2 sw=2 et
