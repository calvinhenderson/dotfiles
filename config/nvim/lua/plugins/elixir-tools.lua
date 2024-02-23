-- [[ Configure Elixir and ElixirLS ]]

local elixir = require("elixir")
local elixirls = require("elixir.elixirls")

elixir.setup {
  nextls = { enable = true },
  credo = {},
  elixirls = {
    enable = true,
    settings = elixirls.settings {
      dialyzerEnabled = true,
      enableTestLenses = true,
    },
    on_attach = function(client, bufnr)
      -- Call the default on_attach
      require('plugins.mason.on_attach')(client, bufnr)

      -- Add some additional keybinds
      vim.keymap.set("n", "<leader>fp", ":ElixirFromPipe<cr>",
        { buffer = true, noremap = true, desc = "Convert [F]rom [P]ipe" })
      vim.keymap.set("n", "<leader>tp", ":ElixirToPipe<cr>",
        { buffer = true, noremap = true, desc = "Convert [T]o [P]ipe" })
      vim.keymap.set("v", "<leader>em", ":ElixirExpandMacro<cr>",
        { buffer = true, noremap = true, desc = "[E]xpand [M]acro" })

      vim.keymap.set("n", "<F5>", ":Mix test<CR>",
        { buffer = true, noremap = true, desc = "Execute test suite" })
      vim.keymap.set("n", "<F8>", ":Mix deps.get<CR>",
        { buffer = true, noremap = true, desc = "Sync dependencies" })
    end,
  }
}
