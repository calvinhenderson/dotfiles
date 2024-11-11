return {
  "L3MON4D3/LuaSnip",
  config = function(plugin, opts)
    -- include the default astronvim config that calls the setup call
    require("astronvim.plugins.configs.luasnip")(plugin, opts)
    -- load snippets
    require("luasnip.loaders.from_snipmate").lazy_load()
  end,
}
