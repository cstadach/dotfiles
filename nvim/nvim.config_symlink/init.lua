-- disable netrw at the very start of your init.lua (strongly advised)
-- this disables Explore
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = "'"
vim.g.maplocalleader = "'"

require "user.plugins"
require "user.options"
require "user.keymaps"

-- Open nvim-tree on startup when no file or directory is given
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local arg = vim.fn.argv(0)
    if type(arg) == 'string' and (arg == '' or vim.fn.isdirectory(arg) == 1) then
      require('nvim-tree.api').tree.open()
    end
  end,
})
