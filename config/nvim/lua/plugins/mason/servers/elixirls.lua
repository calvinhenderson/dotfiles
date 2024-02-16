return {
  cmd = { vim.fn.expand(require 'plugins.elixirls'.install() .. "/language_server.sh") },
  elixirLS = {
    dialyzerEnabled = true,
    suggestSpecs = true,
    signatureAfterComplete = true
  }
}

-- vim: ts=2 sts=2 sw=2 et
