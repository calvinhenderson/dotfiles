-- Set the plist file type to xml
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.plist" },
  command = "set ft=xml"
})

-- Auto-quit nvim when NvimTree is last buffer
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
      vim.cmd "quit"
    end
  end
})

-- Pandoc syntax for markdown
local au_pandoc = vim.api.nvim_create_augroup("pandoc", { clear = true })
vim.api.nvim_create_autocmd("filetype", {
  pattern = { "pandoc" },
  callback = function()
    vim.cmd([[
      PandocFolding none
      set spell wrap colorcolumn=80
    ]])
  end,
  group = au_pandoc
})

-- vim: ts=2 sts=2 sw=2 et
