-- [[ Language Servers ]]
-- A list of server names can be found here:
--  https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers

-- Setup mason so it can manage external tooling
require('mason').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers are installed
local servers = require('plugins.mason.servers')
local mason_lspconfig = require 'mason-lspconfig'
mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    local lsp_options = {
      capabilities = capabilities,
      on_attach = require('plugins.mason.on_attach'),
      single_file_support = true,
    }

    local server_opts = servers[server_name] or {}
    require('lspconfig')[server_name].setup(vim.tbl_extend("force", lsp_options, server_opts))
  end,
}

-- vim: ts=2 sts=2 sw=2 et
