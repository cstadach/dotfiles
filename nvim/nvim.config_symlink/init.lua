-- disable netrw at the very start of your init.lua (strongly advised)
-- this disables Explore
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require "user.plugins"
require "user.options"
require "user.keymaps"
require "user.lsp_signature"
require "user.luasnip"
require "user.mason"
require "user.nvim-cmp"
require "user.nvim-tree"
require "user.nvim-treesiter"
require "user.telescope"
