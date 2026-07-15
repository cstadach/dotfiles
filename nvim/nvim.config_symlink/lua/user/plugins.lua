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

  -- Editing utilities (loaded immediately, lightweight)
  'tpope/vim-surround',
  'tpope/vim-repeat',
  'tpope/vim-sleuth',
  { 'tpope/vim-dispatch',    cmd = { 'Dispatch', 'Make', 'Focus', 'Start' } },
  { 'tpope/vim-unimpaired',  event = 'BufReadPost' },
  { 'tpope/vim-abolish',     event = 'BufReadPost' },
  { 'tpope/vim-endwise',     event = 'InsertEnter' },
  { 'folke/which-key.nvim',  event = 'VeryLazy', opts = {} },
  { 'numToStr/Comment.nvim', event = 'BufReadPost', opts = {} },

  -- Git
  { 'tpope/vim-fugitive',   cmd = { 'Git', 'Gdiff', 'Gblame', 'Gpush', 'Gpull' } },
  { 'tpope/vim-rhubarb',    dependencies = 'tpope/vim-fugitive' },
  { 'sindrets/diffview.nvim', cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewToggleFiles' } },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPre',
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
  { 'rhadley-recurly/vim-terragrunt', ft = { 'terragrunt', 'hcl' } },
  {
    'hashivim/vim-terraform',
    ft = { 'terraform', 'tf', 'hcl' },
    config = function()
      vim.g.terraform_fmt_on_save = 1
    end,
  },

  -- AI / Copilot
  {
    'github/copilot.vim',
    event = 'InsertEnter',
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
    cmd = { 'CopilotChat', 'CopilotChatToggle' },
    keys = {
      { '<leader>aa', function() require('CopilotChat').toggle() end, desc = 'Toggle CopilotChat' },
    },
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

      vim.schedule(function()
        local path = get_history_path()
        if path then
          local history_file = path .. '/.copilot_session.json'
          if vim.fn.filereadable(history_file) == 1 then
            require('CopilotChat').load('.copilot_session', path)
          end
        end
      end)
    end,
  },

  -- LSP
  {
    'folke/lazydev.nvim',
    opts = {
      library = {
        { path = 'luvit-meta/library', words = { 'vim%.uv' } },
      },
    },
    dependencies = { 'Bilal2453/luvit-meta' },
    },
    {
      'neovim/nvim-lspconfig',
      event = 'BufReadPre',
      dependencies = {
        { 'williamboman/mason.nvim', config = true },
        'williamboman/mason-lspconfig.nvim',
        { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} },
      },
      config = function()
        require 'user.mason'
      end,
    },
    {
      'ray-x/lsp_signature.nvim',
      event = 'LspAttach',
      config = function()
        require 'user.lsp_signature'
      end,
    },

    -- Completion
    {
      'hrsh7th/nvim-cmp',
      event = 'InsertEnter',
      dependencies = {
        'hrsh7th/cmp-nvim-lsp',
        {
          'L3MON4D3/LuaSnip',
          dependencies = { 'rafamadriz/friendly-snippets' },
          config = function()
            require 'user.luasnip'
          end,
        },
        'saadparwaiz1/cmp_luasnip',
      },
      config = function()
        require 'user.nvim-cmp'
      end,
    },

    -- Themes
    {
      'EdenEast/nightfox.nvim',
      lazy = false,
      priority = 1000,
      config = function()
        require('nightfox').setup {}
        vim.o.background = 'dark'
        vim.cmd.colorscheme 'nightfox'
      end,
    },
    {
      'catppuccin/nvim',
      name = 'catppuccin',
      lazy = true,
      config = function()
        require('catppuccin').setup {
          background = { light = 'latte', dark = 'mocha' },
        }
      end,
    },

    -- UI
    {
      'nvim-lualine/lualine.nvim',
      event = 'VeryLazy',
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
      event = 'BufReadPre',
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
      event = 'BufReadPost',
      main = 'ibl',
      opts = { indent = { char = '┊' } },
    },

    -- File tree
    {
      'nvim-tree/nvim-tree.lua',
      version = '*',
      cmd = { 'NvimTreeToggle', 'NvimTreeFocus', 'NvimTreeFindFile' },
      keys = {
        { '<leader>tt', '<cmd>NvimTreeToggle<cr>', silent = true, desc = 'Toggle NvimTree' },
      },
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require 'user.nvim-tree'
      end,
    },

    -- Language-specific
    {
      'fatih/vim-go',
      ft = { 'go' },
      build = ':GoUpdateBinaries',
      config = function()
        vim.g.go_gopls_enabled = 0
        vim.g.go_def_mapping_enabled = 0
        vim.g.go_doc_keywordprg_enabled = 0
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
    {
      'nvim-telescope/telescope.nvim',
      version = '*',
      cmd = 'Telescope',
      keys = {
        { '<leader>ff', '<cmd>Telescope find_files<cr>',   desc = '[F]ind [F]iles' },
        { '<leader>fg', '<cmd>Telescope live_grep<cr>',    desc = '[F]ind by [G]rep' },
        { '<leader>fw', '<cmd>Telescope grep_string<cr>',  desc = '[F]ind current [W]ord' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>',      desc = '[F]ind [B]uffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>',    desc = '[F]ind [H]elp' },
      { '<leader>fd', '<cmd>Telescope diagnostics<cr>',  desc = '[F]ind [D]iagnostics' },
      { '<leader>fr', '<cmd>Telescope lsp_references<cr>', desc = '[F]ind [R]eferences' },
      { '<leader>?',  '<cmd>Telescope oldfiles<cr>',     desc = '[?] Find recently opened files' },
      { '<leader><space>', '<cmd>Telescope buffers<cr>', desc = '[ ] Find existing buffers' },
      { '<leader>/',  function()
        require('telescope.builtin').current_buffer_fuzzy_find(
          require('telescope.themes').get_dropdown { winblend = 10, previewer = false }
        )
      end, desc = '[/] Fuzzily search in current buffer' },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require 'user.telescope'
    end,
  },
  {
    'nvim-telescope/telescope-fzf-native.nvim',
    build = 'make',
    cond = function()
      return vim.fn.executable 'make' == 1
    end,
  },

  -- PlatformIO
  {
    'anurag3301/nvim-platformio.lua',
    cmd = { 'Pioinit', 'Piorun', 'Piolib', 'Piomon', 'Piodebug' },
    cond = function()
      return vim.fn.executable('pio') == 1
    end,
    dependencies = {
      { 'akinsho/toggleterm.nvim' },
      { 'nvim-telescope/telescope.nvim' },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-lua/plenary.nvim' },
      { 'folke/which-key.nvim' },
    },
  { import = 'custom.plugins' },

},
  checker = { enabled = true, notify = true, frequency = 86400 },
  performance = {
    rtp = {
      disabled_plugins = {
        'gzip', 'matchit', 'matchparen', 'netrwPlugin',
        'tarPlugin', 'tohtml', 'tutor', 'zipPlugin',
      },
    },
  },
})
