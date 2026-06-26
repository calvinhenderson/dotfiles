return {
  {
    "hedyhli/outline.nvim",
    cmd = "Outline",
    keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
    opts = {
      outline_window = {
        position = "right",
        width = 25,
        relative_width = true,
        auto_width = {
          enabled = true,
          max_width = 30,
          include_symbol_details = false,
        },
        auto_jump = true,
        center_on_jump = true,
      },
      outline_items = {
        show_symbol_details = true,
        show_symbol_lineno = true,
        highlight_hovered_item = true,
        auto_set_cursor = true,
      },
    },
  },
}
