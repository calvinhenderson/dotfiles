require 'nvim-tree'.setup {
  sort_by = 'case_sensitive',
  renderer = {
    icons = {
      show = {
        file = true,
        folder = true,
        -- Set to false when using custom icons to prevent a duplicate arrow
        folder_arrow = true,
        git = true,
        modified = true,
      },
    },
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },
  on_attach = function(bufnr)
    local api = require 'nvim-tree.api'

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    api.config.mappings.default_on_attach(bufnr)

    -- Remove Open In Place keymap in favor of scrolling
    vim.keymap.del('n', '<C-e>', { buffer = bufnr })
  end
}

local function open_nvim_tree(data)
  -- buffer is a real file on the disk
  local real_file = vim.fn.filereadable(data.file) == 1

  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

  if not real_file and not no_name then
    return
  end

  require 'nvim-tree.api'.tree.toggle({ focus = false, find_file = true, })
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })
vim.keymap.set('n', '<leader>tt', require('nvim-tree.api').tree.toggle, { desc = '[T]ree [T]oggle' })
vim.keymap.set('n', '<leader>tb', require('nvim-tree.api').tree.find_file, { desc = 'Open [T]ree for [B]uffer' })

-- vim: ts=2 sts=2 sw=2 et
