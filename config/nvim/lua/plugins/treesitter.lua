if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "c",
      "cpp",
      "css",
      "elixir",
      "heex",
      "html",
      "javascript",
      "lua",
      "typescript",
      "vim",
      "vimdoc"
      -- add more arguments for adding more treesitter parsers
    },
  },
}
