local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
local fs_stat = (vim.uv or vim.loop).fs_stat

if not fs_stat(lazypath) then
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
vim.lsp.log.set_level("off")

require('lazy').setup({

  -- Editing utilities
  'tpope/vim-surround',
  'tpope/vim-dispatch',
  'tpope/vim-unimpaired',
  'tpope/vim-abolish',
  'tpope/vim-repeat',
  'tpope/vim-endwise',
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
  {
    'hashivim/vim-terraform',
    config = function()
      vim.g.terraform_fmt_on_save = 1
    end,
  },

  -- AI / Copilot
  {
    'github/copilot.vim',
    config = function()
      vim.g.copilot_filetypes = {
        ['*']          = false,
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
      }
    end,
  },
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    dependencies = {
      { 'nvim-lua/plenary.nvim', branch = 'master' },
    },
    build = 'make tiktoken',
    opts = {
      model = 'claude-sonnet-4.6',
    },
    config = function(_, opts)
      local function get_history_path()
        local cwd = vim.fn.getcwd()
        local result = vim.fn.systemlist({ 'git', '-C', cwd, 'rev-parse', '--show-toplevel' })

        if vim.v.shell_error == 0 and result[1] and result[1] ~= '' and result[1] == cwd then
          return cwd
        end

        return nil
      end

      opts.callback = function()
        local path = get_history_path()
        if path then
          require('CopilotChat').save('.copilot_session', path)
        end
      end

      require('CopilotChat').setup(opts)

      vim.api.nvim_create_autocmd('VimEnter', {
        once = true,
        callback = function()
          local path = get_history_path()
          if path then
            local history_file = path .. '/.copilot_session.json'
            if vim.fn.filereadable(history_file) == 1 then
              require('CopilotChat').load('.copilot_session', path)
            end
          end
        end,
      })

      vim.keymap.set('n', '<leader>aa', function()
        require('CopilotChat').toggle()
      end, { desc = 'Toggle CopilotChat' })
    end,
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'williamboman/mason.nvim', config = true },
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
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
    ft = { 'markdown' },
    build = function()
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
    branch = 'main',
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
