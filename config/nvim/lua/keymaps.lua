-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set('n', '<leader><leader>e', ':edit ~/.config/nvim/init.lua<CR>', { silent = true })

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '<Up>', "v:count == 0 ? 'gk' : '<Up>'", { expr = true, silent = true })
vim.keymap.set('n', '<Down>', "v:count == 0 ? 'gj' : '<Down>'", { expr = true, silent = true })

-- Buffers
vim.keymap.set('n', '<leader>x', ':bp|bd #<CR>', { desc = 'E[x]it buffer, keep pane' })
vim.keymap.set('n', '<leader>X', ':qa<CR>', { desc = 'E[x]it all open buffers' })
vim.keymap.set('n', '<C-h>', ':bp<CR>', { desc = 'Switch to previous buffer' })
vim.keymap.set('n', '<C-l>', ':bn<CR>', { desc = 'Switch to next buffer' })

-- Splits
vim.keymap.set('n', '<leader>H', ':vert resize -2<CR>', { desc = 'Shrink pane width' })
vim.keymap.set('n', '<leader>L', ':vert resize +2<CR>', { desc = 'Grow pane width' })
vim.keymap.set('n', '<leader>J', ':vert resize -2<CR>', { desc = 'Shrink pane height' })
vim.keymap.set('n', '<leader>K', ':vert resize +2<CR>', { desc = 'Grow pane height' })

-- Tabs
vim.keymap.set('n', '<leader>tn', ':tabnew<CR>', { desc = '[T]ab [N]ew' })
vim.keymap.set('n', '<leader>tq', ':tabclose<CR>', { desc = '[T]ab [C]lose' })
vim.keymap.set('n', '<M-h>', ':tabp<CR>', { desc = '[T]ab [J]Previous' })
vim.keymap.set('n', '<M-l>', ':tabn<CR>', { desc = '[T]ab [K]Next' })

-- vim: ts=2 sts=2 sw=2 et
