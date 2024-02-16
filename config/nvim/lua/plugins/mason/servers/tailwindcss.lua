return {
  filetypes = { "html", "elixir", "eelixir", "heex" },
  init_options = {
    userLanguages = {
      elixir = "html-eex",
      eelixir = "html-eex",
      heex = "html-eex"
    },
  },
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = { 'class[:]\\s*"([^"]*)"' },
      },
    },
  },
}

-- vim: ts=2 sts=2 sw=2 et
