local schemastore_ok, schemastore = pcall(require, 'schemastore')
local on_attach = function(_, bufnr)
  local nmap = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format({ async = true })
  end, { desc = 'Format current buffer with LSP' })
end

local lsp_servers = {
  gopls       = {},
  pyright     = {},
  terraformls = {},
  ts_ls       = {},
  bashls      = {},
  ansiblels   = {
    filetypes = { 'yaml.ansible' },
    ansible   = {
      path = { ansibleLint = { enabled = false } },
    },
  },
  jsonls      = {
    json = {
      schemas = schemastore_ok and schemastore.json.schemas() or {},
      validate = { enable = true },
    },
  },
  yamlls      = {
    filetypes = { 'yaml' }, -- yaml.ansible is excluded, so ansiblels handles it exclusively
    yaml = {
      format      = {
        enable = true,
        singleQuote = true,
      },
      schemas     = vim.tbl_extend('force',
        schemastore_ok and schemastore.yaml.schemas() or {},
        {
          ['https://gitlab.com/gitlab-org/gitlab-foss/-/raw/master/app/assets/javascripts/editor/schema/ci.json'] = {
            '/.gitlab-ci.yml',
            'devops/gitlab-ci-configurations/**/*.yml',
          },
          kubernetes = {
            '**/deployment.yaml',
            '**/ingress.yaml',
            '**/kustomization.yaml',
            '**/service.yaml',
            '**/httproute.yaml',
            '**/refgrants.yaml',
          },
        }
      ),
      schemaStore = { enable = false, url = '' },
      customTags  = { '!reference sequence' },
      validate    = true,
      completion  = true,
      hover       = true,
    },
  },

  lua_ls      = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      diagnostics = { globals = { 'vim' } },
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(lsp_servers),
  automatic_enable = false,
}

for server_name, server_settings in pairs(lsp_servers) do
  vim.lsp.config(server_name, {
    capabilities = capabilities,
    on_attach = on_attach,
    settings = server_settings,
  })
end

vim.lsp.enable(vim.tbl_keys(lsp_servers))
vim.filetype.add({
  pattern = {
    ['.*/ansible/.*%.ya?ml'] = 'yaml.ansible',
    ['.*%.([%w]+)%.j2'] = function(_, _, ext)
      return ext .. '.jinja'
    end,
    ['.*%.j2'] = 'jinja',
  },
})
