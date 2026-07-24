-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
-- [[ Basic Keymaps ]]

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- clear search on return
map('n', '<cr><cr>', ':nohlsearch<cr>')
-- Diagnostic keymaps
map('n', '[d', function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Go to previous diagnostic message" })
map('n', ']d', function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Go to next diagnostic message" })
map('n', '<leader>e', vim.diagnostic.open_float, { desc = "Open floating diagnostic message" })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = "Open diagnostics list" })

 -- Easily Switch Windows
map('n', '<C-j>', '<C-w><C-j>')
map('n', '<C-k>', '<C-w><C-k>')
map('n', '<C-l>', '<C-w><C-l>')
map('n', '<C-h>', '<C-w><C-h>')

-- Buffer picking and sorting
map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)
map('n', '<Space>bb', '<Cmd>BufferLineSortByTabs<CR>', opts)
