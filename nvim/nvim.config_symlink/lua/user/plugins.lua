local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

local ok, local_cfg = pcall(require, 'local')
local profile = (ok and local_cfg.profile) or 'work'

require('lazy').setup({

  -- Editing utilities
  'tpope/vim-surround',
  'tpope/vim-dispatch',
  'tpope/vim-unimpaired',
  'tpope/vim-abolish',
  'tpope/vim-repeat',
  'tpope/vim-endwise',
  'tpope/vim-commentary',
  'tpope/vim-sleuth',
  { 'folke/which-key.nvim', opts = {} },
  { 'numToStr/Comment.nvim', opts = {} },

  -- Git
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',
  'sindrets/diffview.nvim',
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  -- Infrastructure / DevOps
  'rhadley-recurly/vim-terragrunt',
  { 'hashivim/vim-terraform' },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = {
      formatters_by_ft = {
        go         = { 'goimports', 'gofmt' },
        python     = { 'ruff_format' },
        typescript = { 'prettier' },
        javascript = { 'prettier' },
        yaml       = { 'prettier' },
        json       = { 'prettier' },
        sh         = { 'shfmt' },
        bash       = { 'shfmt' },
        terraform  = { 'terraform_fmt' },
        hcl        = { 'terraform_fmt' },
      },
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
    },
  },
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    opts = {
      ensure_installed = {
        'goimports', 'ruff', 'prettier', 'shfmt',
        'tflint', 'ansible-lint',
      },
    },
  },

  -- AI / Copilot (work profile)
  {
    'github/copilot.vim',
    cond = profile == 'work',
    config = function()
      vim.g.copilot_filetypes = {
        ['*']          = false,
        ['go']         = true,
        ['lua']        = true,
        ['tf']         = true,
        ['yaml']       = true,
        ['hcl']        = true,
        ['jinja']      = true,
        ['dockerfile'] = true,
        ['python']     = true,
        ['javascript'] = true,
        ['typescript'] = true,
        ['html']       = true,
        ['css']        = true,
        ['sh']         = true,
      }
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    cond = profile == 'work',
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    config = function(_, opts)
      require('CopilotChat').setup(opts)
      vim.keymap.set('n', '<leader>aa', function()
        require('CopilotChat').toggle()
      end, { desc = 'Toggle CopilotChat' })
    end,
  },

  -- AI / avante.nvim with Claude (home profile)
  -- API key is fetched from 1Password on first use (Touch ID), then cached
  -- for the session. Same secret reference as claude-sandbox.zsh.
  {
    'yetone/avante.nvim',
    cond = profile == 'home',
    event = 'VeryLazy',
    build = 'make',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'stevearc/dressing.nvim',
      'nvim-lua/plenary.nvim',
      'MunifTanjim/nui.nvim',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      provider = 'claude',
      providers = {
        claude = {
          endpoint   = 'https://api.anthropic.com',
          model      = 'claude-sonnet-4-6',
          max_tokens = 8192,
          api_key_name = "cmd:op read 'op://Private/Anthropic/credential'",
        },
      },
    },
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
      'folke/neodev.nvim',
    },
  },
  { 'ray-x/lsp_signature.nvim', config = false },

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
      'rafamadriz/friendly-snippets',
    },
  },

  -- Themes
  {
    'EdenEast/nightfox.nvim',
    config = function()
      require('nightfox').setup {}
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'nightfox'
    end,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        background = { light = 'latte', dark = 'mocha' },
      }
      -- vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- UI
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'EdenEast/nightfox.nvim' },
    opts = {
      options = {
        icons_enabled = true,
        theme = 'nightfox',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_c = {
          { 'filename', file_status = true, newfile_status = true, path = 1 },
        },
      },
    },
  },
  {
    'romgrk/barbar.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    version = '^1.0.0',
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      animation = false,
      insert_at_start = false,
      insert_at_end = true,
    },
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = { indent = { char = '┊' } },
  },

  -- File tree
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },

  -- Language-specific
  {
    'fatih/vim-go',
    build = ':GoUpdateBinaries',
    config = function()
      vim.g.go_def_mode = 'gopls'
    end,
  },
  {
    'iamcco/markdown-preview.nvim',
    config = function()
      vim.fn['mkdp#util#install']()
    end,
  },

  -- Telescope / Fuzzy finding
  { 'nvim-telescope/telescope.nvim', version = '*', dependencies = { 'nvim-lua/plenary.nvim' } },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  -- Treesitter
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    build = ':TSUpdate',
  },

  -- PlatformIO
  {
    'anurag3301/nvim-platformio.lua',
    cond = function()
      return vim.fn.executable('pio') == 1
    end,
    dependencies = {
      { 'akinsho/toggleterm.nvim' },
      { 'nvim-telescope/telescope.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'folke/which-key.nvim' },
      { 'nvim-treesitter/nvim-treesitter' },
    },
  },

  { import = 'custom.plugins' },

}, {
  checker = { enabled = true, notify = true, frequency = 86400 },
})
